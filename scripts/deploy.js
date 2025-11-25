const hre = require("hardhat");

async function main() {
  console.log("🚀 Starting deployment to Edu Chain...");

  // 1. Deploy Token (Phii Coin)
  const token = await hre.ethers.deployContract("PhiiCoin");
  await token.waitForDeployment();
  const tokenAddress = await token.getAddress();
  console.log(`✅ PhiiCoin deployed to: ${tokenAddress}`);

  // 2. Deploy Payroll Contract (Bawa alamat token tadi)
  const payroll = await hre.ethers.deployContract("PhiiPayroll", [tokenAddress]);
  await payroll.waitForDeployment();
  const payrollAddress = await payroll.getAddress();
  console.log(`✅ PhiiPayroll deployed to: ${payrollAddress}`);

  console.log("-----------------------------------");
  console.log("Simpan alamat ini untuk submit tugas!");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
