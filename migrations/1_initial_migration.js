var Migrations = artifacts.require("./Migrations.sol");
var ProxiedTokenContract = artifacts.require("ProxiedToken");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(ProxiedTokenContract);
};
