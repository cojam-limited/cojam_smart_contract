const Token = artifacts.require('CojamToken');
const Market = artifacts.require('CojamMarket');

module.exports = function(deployer, network, account) {
  let token;
    deployer.then( async ()=>{
      //token = await deployer.deploy(Token);
    //}).then( async ()=>{
      let market = await deployer.deploy(Market, "0xd6cdab407f47afaa8800af5006061db8dc92aae7");
    });
}
