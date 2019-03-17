const Web3 = require('web3');
const web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider("http://localhost:7545"));

exports.ethTaxAddress = "0xcfeb869f69431e42cdb54a4f4f105c19c080a601";
exports.taxableAccountAddress = "0x79183957be84c0f4da451e534d5ba5ba3fb9c696";

exports.ethTaxAbi = require('../build/contracts/EthTax.json').abi;
exports.taxableAccountAbi = require('../build/contracts/TaxableAccount.json').abi;

exports.ethTax = web3.eth.contract(exports.ethTaxAbi).at(exports.ethTaxAddress);
exports.taxableAccount = web3.eth.contract(exports.taxableAccountAbi).at(exports.taxableAccountAddress);
exports.web3 = web3;
exports.accounts = {
  "ethTaxOwner": web3.eth.accounts[0],
  "accountOwners": [web3.eth.accounts[1], web3.eth.accounts[2]]
};
