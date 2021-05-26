require('dotenv').config();
const Owner = require('../build/contracts/Ownable.json');
const Caver = require('caver-js');
// const caver = new Caver("https://api.cypress.klaytn.net:8651");
const caver = new Caver('https://api.baobab.klaytn.net:8651');

// TODO: enter the private key of token owner
const privateKey = process.env.PRIVATE_KEY;
caver.klay.accounts.wallet.add(privateKey);
const owner = new caver.klay.Contract(Owner.abi, '0x7d774689E9880F7D19c77a67DA54c766DD6887fD');

async function changeOwner(newOwner) {
  const from = caver.klay.accounts.wallet.getAccount(0).address;
  const res = await owner.methods.transferOwnership(newOwner).send({ from: from, gas: 100000 });
  console.log(res);
}

changeOwner('0x4a1667cf934796067adbddf456c95ef91658b403');

// 실행 - node ./scripts/changeOwner.js
