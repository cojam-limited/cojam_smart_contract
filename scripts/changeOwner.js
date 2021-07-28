require('dotenv').config();
const Owner = require('../build/contracts/Ownable.json');
const Caver = require('caver-js');
const IS_DEV = true;

async function changeOwner(newOwner) {
  const caver = IS_DEV?(new Caver('https://api.baobab.klaytn.net:8651'))
                      :(new Caver("https://kaikas.cypress.klaytn.net:8651"));

  // TODO: enter the private key of token owner
  const privateKey = IS_DEV?process.env.PRIVATE_KEY
                           :process.env.PRIVATE_KEY_CYPRESS;

  caver.klay.accounts.wallet.add(privateKey);
  const owner = new caver.klay.Contract(Owner.abi, '0x5C4fDBD36cf38e4794951254D4285b53f545e2B4');

  const from = caver.klay.accounts.wallet.getAccount(0).address;
  const res = await owner.methods.transferOwnership(newOwner).send({ from: from, gas: 100000 });
  console.log(res);
}

async function currentOwner() {
  const caver = IS_DEV?(new Caver('https://api.baobab.klaytn.net:8651'))
                      :(new Caver("https://kaikas.cypress.klaytn.net:8651"));

  // TODO: enter the private key of token owner
  const privateKey = IS_DEV?process.env.PRIVATE_KEY
                           :process.env.PRIVATE_KEY_CYPRESS;

  caver.klay.accounts.wallet.add(privateKey);
  const owner = new caver.klay.Contract(Owner.abi, '0x5C4fDBD36cf38e4794951254D4285b53f545e2B4');

  const res = await owner.methods.owner().call();
  console.log(res);
}

//changeOwner('0x281650e1270265dde07ae465d179eb560132eafa');
currentOwner();

// 실행 - node ./scripts/changeOwner.js
