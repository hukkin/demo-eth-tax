var EthTax = artifacts.require("./EthTax.sol");

module.exports = function(deployer) {
  deployer.deploy(EthTax);
};
