require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    educhain: {
      url: "https://rpc.open-campus-codex.gelato.digital",
      chainId: 656476,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
  etherscan: {
    apiKey: {
      educhain: "empty"
    },
    customChains: [
      {
        network: "educhain",
        chainId: 656476,
        urls: {
          apiURL: "https://edu-chain-testnet.blockscout.com/api",
          browserURL: "https://edu-chain-testnet.blockscout.com"
        }
      }
    ]
  }
};
