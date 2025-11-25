// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract PhiiPayroll is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    IERC20 public paymentToken;
    uint256 public constant SECONDS_IN_MONTH = 30 days;

    struct Employee {
        uint256 monthlySalary;
        uint256 lastPayTimestamp;
        uint256 withdrawnThisPeriod;
        bool isActive;
        bool exists;
    }

    mapping(address => Employee) public employees;

    event EmployeeRegistered(address indexed employee, uint256 salary);
    event SalaryDeposited(uint256 amount);
    event AdvanceWithdrawn(address indexed employee, uint256 amount);
    event SalarySettled(address indexed employee, uint256 amount);
    
    constructor(address _tokenAddress) Ownable(msg.sender) {
        require(_tokenAddress != address(0), "Invalid token address");
        paymentToken = IERC20(_tokenAddress);
    }

    // --- Employer Functions ---
    function registerEmployee(address _employee, uint256 _monthlySalary) external onlyOwner {
        require(_employee != address(0), "Invalid address");
        require(_monthlySalary > 0, "Salary > 0");
        
        employees[_employee] = Employee({
            monthlySalary: _monthlySalary,
            lastPayTimestamp: block.timestamp,
            withdrawnThisPeriod: 0,
            isActive: true,
            exists: true
        });
        emit EmployeeRegistered(_employee, _monthlySalary);
    }

    function fund(uint256 _amount) external onlyOwner {
        paymentToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit SalaryDeposited(_amount);
    }

    // --- Employee Functions (EWA) ---
    function calculateAccrued(address _employee) public view returns (uint256) {
        Employee memory emp = employees[_employee];
        if (!emp.isActive) return 0;

        uint256 timeElapsed = block.timestamp - emp.lastPayTimestamp;
        if (timeElapsed > SECONDS_IN_MONTH) timeElapsed = SECONDS_IN_MONTH;

        return (emp.monthlySalary * timeElapsed) / SECONDS_IN_MONTH;
    }

    function requestAdvance(uint256 _amount) external nonReentrant whenNotPaused {
        Employee storage emp = employees[msg.sender];
        require(emp.isActive, "Not active");

        uint256 accrued = calculateAccrued(msg.sender);
        uint256 available = accrued - emp.withdrawnThisPeriod;

        require(_amount <= available, "Amount exceeds accrued salary");
        require(emp.withdrawnThisPeriod + _amount <= (emp.monthlySalary / 2), "Max 50% advance allowed");
        require(paymentToken.balanceOf(address(this)) >= _amount, "System underfunded");

        emp.withdrawnThisPeriod += _amount;
        paymentToken.safeTransfer(msg.sender, _amount);
        
        emit AdvanceWithdrawn(msg.sender, _amount);
    }

    function settleSalary() external nonReentrant {
        Employee storage emp = employees[msg.sender];
        require(block.timestamp >= emp.lastPayTimestamp + SECONDS_IN_MONTH, "Cycle not finished");

        uint256 remaining = emp.monthlySalary - emp.withdrawnThisPeriod;
        
        emp.lastPayTimestamp = block.timestamp;
        emp.withdrawnThisPeriod = 0;

        if (remaining > 0) {
            require(paymentToken.balanceOf(address(this)) >= remaining, "System underfunded");
            paymentToken.safeTransfer(msg.sender, remaining);
        }
        emit SalarySettled(msg.sender, remaining);
    }
}
