var Migrations = artifacts.require("./Migrations.sol");
var OriginTokenContract = artifacts.require("OriginToken");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(OriginTokenContract);
};
