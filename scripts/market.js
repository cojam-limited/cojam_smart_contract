require('dotenv').config();
const Market = require('../build/contracts/CojamMarket.json');
const Caver = require('caver-js');
// const caver = new Caver("https://api.cypress.klaytn.net:8651");
const caver = new Caver('https://api.baobab.klaytn.net:8651');

// TODO: enter the private key of token
const privateKey = process.env.PRIVATE_KEY;
caver.klay.accounts.wallet.add(privateKey);
const market = new caver.klay.Contract(Market.abi, '0x7d774689E9880F7D19c77a67DA54c766DD6887fD');

async function test() {
  const from = caver.klay.accounts.wallet.getAccount(0).address;
  const res = await market.methods.getMarket(2021040900000003).send({ from: from, gas: 100000 });
  console.log(res);
}

test();
// 실행 - node ./scripts/changeOwner.js
