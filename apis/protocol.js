const ethers = require('ethers');
const fs = require('fs');
// const Tx = require("ethereumjs-tx"); // 这个版本一定要1.3.7
// const BigNumber = require("bignumber.js");
const abi = JSON.parse(fs.readFileSync("./abis/pabi"));
const provider = new ethers.getDefaultProvider('https://devnet-rpc.cess.cloud/ws/');
const privateKey = "82b46d10cd14ec7afe513bcb1f2283125255798dda67e0c35293954dffe206d3";
const wallet = new ethers.Wallet(privateKey, provider);
const ContractAddr = '0x11Fc59Abaa21999867BBa3De1ff824C2F3FE586E';
const contract = new ethers.Contract(ContractAddr, abi, provider);
const contractWithSigner = contract.connect(wallet);

module.exports = {
    isTokenOwner: async (req, res) => {
        let tx = await contractWithSigner.isTokenOwner("0xFd0Cc11A9ffbA29F7db7734b6dc39b1e5212Bb1c", "39544152962685682738802395746813564884410831556687539743456329902945155131759");
        console.log(tx.hash);
        // "0xaf0068dcf728afa5accd02172867627da4e6f946dfb8174a7be31f01b11d5364"

        console.log("isTokenOwner:" + JSON.stringify(tx) + "\n");

        res.json({
            "msg": "ok"
        });
    }

    
}