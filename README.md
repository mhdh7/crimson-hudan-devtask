# PhiiPayroll - Earned Wage Access (EWA) System
**Mancer Crimson Season 2 - Proof of Skill Mission**

PhiiPayroll is a decentralized payroll system deployed on Edu Chain Testnet. It empowers employees with **Earned Wage Access (EWA)**, allowing them to withdraw accrued salary in real-time before payday, while ensuring employers maintain full control over fund management.

## 🚀 Features

### For Employers (Admin)
- **Employee Registration:** Onboard employees with fixed monthly salaries.
- **Fund Management:** Deposit ERC-20 tokens (Phii Coin) to fund the payroll pool.
- **Refund Mechanism:** Withdraw excess funds safely.
- **Pausable System:** Emergency stop functionality for security.

### For Employees
- **Real-Time Accrual:** Salary is earned linearly every second.
- **Earned Wage Access (EWA):** Withdraw up to **50%** of accrued salary anytime.
- **Automatic Settlement:** Claim remaining balance at the end of the 30-day cycle.

## 🛠 Tech Stack
- **Language:** Solidity ^0.8.20
- **Framework:** Hardhat
- **Network:** Edu Chain Testnet (Open Campus)
- **Security:** OpenZeppelin (Ownable, ReentrancyGuard, SafeERC20)

## 📦 Installation & Testing

1. **Clone Repository**
   ```bash
   git clone [https://github.com/USERNAME_KAMU/crimson-hudan-devtask.git](https://github.com/USERNAME_KAMU/crimson-hudan-devtask.git)
   cd crimson-hudan-devtask
   npm install
