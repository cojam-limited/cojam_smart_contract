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
  const owner = new caver.klay.Contract(Owner.abi, '0x4f508e75F2Cf4F1c785daEf4A63BE9708c4B3443');

  const from = caver.klay.accounts.wallet.getAccount(0).address;
  const res = await owner.methods.transferOwnership(newOwner).send({ from: from, gas: 100000 });
  console.log(res);
}

changeOwner('0x4a1667cf934796067adbddf456c95ef91658b403');

// 실행 - node ./scripts/changeOwner.js
