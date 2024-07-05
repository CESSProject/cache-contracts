/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-ignition-ethers");

module.exports = {
  solidity: "0.8.24",
  networks: {
    cessdev: {
      url: 'https://devnet-rpc.cess.cloud/ws/', // 输入您的RPC URL
      chainId: 11330, // (hex: 0x504),
      accounts: ['82b46d10cd14ec7afe513bcb1f2283125255798dda67e0c35293954dffe206d3'],
    },
  },
};

