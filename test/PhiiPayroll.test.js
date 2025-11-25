const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("PhiiPayroll System", function () {
  let payroll, token;
  let employer, employee, other;
  const MONTHLY_SALARY = ethers.parseEther("3000"); // Gaji 3000 Token

  beforeEach(async function () {
    [employer, employee, other] = await ethers.getSigners();

    // 1. Deploy Token (Phii Coin)
    const Token = await ethers.getContractFactory("PhiiCoin");
    token = await Token.deploy();
    
    // 2. Deploy Payroll Contract
    const Payroll = await ethers.getContractFactory("PhiiPayroll");
    payroll = await Payroll.deploy(await token.getAddress());

    // 3. Employer kasih duit ke Employer (dari minting awal) & Approve Contract
    // (Di PhiiCoin, msg.sender dapet supply awal, jadi employer udah punya saldo)
    await token.approve(await payroll.getAddress(), ethers.parseEther("1000000"));
  });

  it("Should allow employer to fund the contract", async function () {
    const fundAmount = ethers.parseEther("10000");
    await payroll.fund(fundAmount);
    
    expect(await token.balanceOf(await payroll.getAddress())).to.equal(fundAmount);
  });

  it("Should allow employee to withdraw EWA (50% max)", async function () {
    // 1. Fund Contract
    await payroll.fund(ethers.parseEther("10000"));

    // 2. Register Employee
    await payroll.registerEmployee(employee.address, MONTHLY_SALARY);

    // 3. Percepat waktu 15 hari (setengah bulan)
    // 30 hari = 2592000 detik. 15 hari = 1296000 detik.
    await time.increase(1296000);

    // 4. Cek Accrued (Harusnya sekitar 1500)
    // Employee request advance 1000 (aman karena < 1500 dan < 50% gaji)
    await payroll.connect(employee).requestAdvance(ethers.parseEther("1000"));

    expect(await token.balanceOf(employee.address)).to.equal(ethers.parseEther("1000"));
  });

  it("Should FAIL if employee withdraws > 50%", async function () {
    await payroll.fund(ethers.parseEther("10000"));
    await payroll.registerEmployee(employee.address, MONTHLY_SALARY);
    
    // Percepat waktu sampai akhir bulan (Gaji penuh accrued)
    await time.increase(2592000); 

    // Coba tarik 2000 (Padahal max 50% dari 3000 adalah 1500)
    await expect(
      payroll.connect(employee).requestAdvance(ethers.parseEther("2000"))
    ).to.be.revertedWith("Max 50% advance allowed");
  });
});
