require('dotenv').config();
const HDWalletProvider = require('truffle-hdwallet-provider');
const KlaytnWalletProvider = require("truffle-hdwallet-provider-klaytn");
const mnemonic = 'hello hello';
const infuraKey = '';
module.exports = {
  plugins: ['solidity-coverage'],
  networks: {
    mainnet: {
      provider: function() {
        return new HDWalletProvider(mnemonic, `https://mainnet.infura.io/v3/${infurakey}`);
      },
      port: 8545,
      network_id: 1,
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(mnemonic, `https://ropsten.infura.io/v3/${infuraKey}`);
      },
      port: 8545,
      network_id: '3',
      skipDryRun: true,
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/v3/${infuraKey}`);
      },
      port: 8545,
      network_id: '4',
      skipDryRun: true,
    },
    development: {
      host: 'localhost',
      port: 8545,
      network_id: '*',
    },
    coverage: {
      host: 'localhost',
      network_id: '*',
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01,
    },
    klaytn_testnet: {
      provider: () => new KlaytnWalletProvider(process.env.PRIVATE_KEY, "https://api.baobab.klaytn.net:8651"),
        network_id: '1001', //Klaytn baobab testnet's network id
        gas: '8500000',
        gasPrice: null
    },
    klaytn_mainnet: {
      //provider: () => new KlaytnWalletProvider(process.env.PRIVATE_KEY_CYPRESS, "https://api.cypress.klaytn.net:8651"),
      //provider: () => new KlaytnWalletProvider(process.env.PRIVATE_KEY_CYPRESS, "https://tn.henesis.io/klaytn/mainnet?clientId=30c53153a44235aa2d799189911edec5"),
      provider: () => new KlaytnWalletProvider(process.env.PRIVATE_KEY_CYPRESS, "https://kaikas.cypress.klaytn.net:8651"),
        network_id: '8217', //Klaytn mainnet's network id
        gas: '8500000',
        gasPrice: null
    },
  },

  compilers: {
    solc: {
      version: '0.7.1',
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
        evmVersion: '', //basically verstion defult, petersburg, istanbul use petersburg for klaytn
      },
    },
  },
};
