require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("@openzeppelin/hardhat-upgrades");


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  etherscan: {
    apiKey: {
     baseSepolia: "XAN69HGT8JAGS11VNQHQDDC3EFF8PIIPPA",
    },
    customChains: [
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
         apiURL: "https://api-sepolia.basescan.org/api",
         browserURL: "https://sepolia.basescan.org"
        }
      }
    ]
  },
  networks: {
    baseSepolia: {
      url:"https://base-sepolia.g.alchemy.com/v2/6Up721pmBWAKxXAMGBfJlddgWVeD2xRg",
      accounts: ["6d0cec17bf53b876fd70e2b0a19adab012a65e57b70614366629196dc6ea31fb"],
    },
  },
};