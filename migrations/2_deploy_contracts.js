require('dotenv').config();
const Token = artifacts.require('CojamToken');
const Market = artifacts.require('CojamMarket');

module.exports = function(deployer, network, account) {
  let token;
    deployer.then( async ()=>{
      //token = await deployer.deploy(Token);
    //}).then( async ()=>{
      let market = await deployer.deploy(Market, process.env.TESTNET_CONTRACT_ADDRESS); //테스트넷
      //let market = await deployer.deploy(Market, process.env.MAINNET_CONTRACT_ADDRESS); //메인넷
    });
}
