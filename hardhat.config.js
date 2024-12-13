/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-ignition-ethers");

const fs = require("fs");
const path = require('path')

const data = fs.readFileSync(path.resolve(__dirname, './keyring.json'), 'UTF-8').toString()
let config = JSON.parse(data)

module.exports = {
  solidity: "0.8.24",
  networks: {
    cessdev: {
<<<<<<< HEAD
      url: 'https://testnet-rpc.cess.network/ws/', // 输入您的RPC URL wss://testnet-rpc.cess.network/ws/
=======
      url: 'https://testnet-rpc.cess.cloud/ws/', 
>>>>>>> origin/main
      chainId: 11330, // (hex: 0x504),
      accounts: [config['main_private_key']],
    },
  },
};

