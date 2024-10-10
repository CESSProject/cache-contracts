/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-ignition-ethers");

module.exports = {
  solidity: "0.8.24",
  networks: {
    cessdev: {
      url: 'https://testnet-rpc.cess.cloud/ws/', // 输入您的RPC URL
      chainId: 11330, // (hex: 0x504),
      accounts: [''],
    },
  },
};

