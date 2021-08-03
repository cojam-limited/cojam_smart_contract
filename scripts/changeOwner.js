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
  const owner = new caver.klay.Contract(Owner.abi, '0x864804674770a531b1cd0CC66DF8e5b12Ba84A09'); //운영 새로 배포한 마켓 컨트랙트 주소
  //const owner = new caver.klay.Contract(Owner.abi, '0xC31585Bf0808Ab4aF1acC29E0AA6c68D2B4C41CD'); //운영 새로 배포한 마켓 컨트랙트 주소

  const from = caver.klay.accounts.wallet.getAccount(0).address;
  const res = await owner.methods.transferOwnership(newOwner).send({ from: from, gas: 100000 });
  console.log(res);
}

IS_DEV?(changeOwner('0x4a1667cf934796067adbddf456c95ef91658b403')) //개발 마스터 월넷 Address
    :(changeOwner('0x281650e1270265dde07ae465d179eb560132eafa')); //운영 마스터 월넷 Address

// 실행 - node ./scripts/changeOwner.js
