const Property = artifacts.require("Property");
const Bank = artifacts.require("Bank")

module.exports = function(deployer) {
  deployer.deploy(Property).then(function() {
  	return deployer.deploy(Bank);
  });
};