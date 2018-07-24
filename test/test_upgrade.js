const BigNumber = web3.BigNumber
var chai = require('chai')
chai.use(require('chai-bignumber')(BigNumber))
var expect = chai.expect

const ProxiedToken = artifacts.require("ProxiedToken");
const ProxiedTokenV2 = artifacts.require("ProxiedTokenV2");
const AdminUpgradeabilityProxy = artifacts.require('AdminUpgradeabilityProxy');

contract('ProxiedToken', function([proxyAdmin, tokenOwner, regularUser1, regularUser2]) {
  const startSupply = new BigNumber('1000000000000000000000000000')
  const mintAmount = new BigNumber('500000000000000000000000')
  let proxy
  let tokenV1Impl

  beforeEach(async () => {
    tokenV1Impl = await ProxiedToken.new({from: tokenOwner})
    // NOTE: the following line is not usual. we don't usually make any calls
    // to the underlying contract implementation. this is only needed to make
    // an apples-to-apples gas comparison possible below
    await tokenV1Impl.initialize()
    proxy = await AdminUpgradeabilityProxy.new(tokenV1Impl.address, {from: proxyAdmin})

    // need to call initialize on the proxy, so that the proxy's storage is
    // used
    let token = await ProxiedToken.at(proxy.address)
    // initialize and all other proxied calls *must* happen with an account
    // that's not proxyAdmin
    await token.initialize({from: tokenOwner})
  })

  it("should retain minted tokens after contract upgrade", async () => {
    // create proxy that points to token v1 contract
    let token = await ProxiedToken.at(proxy.address)
    let balance = await token.balanceOf(tokenOwner, {from: regularUser1})
    expect(balance).to.be.bignumber.equal(startSupply)

    // mint 50,000 tokens and grant them to regularUser
    await token.mint(regularUser1, mintAmount, {from: tokenOwner})
    let user1Balance = await token.balanceOf(regularUser1, {from: regularUser1})
    expect(user1Balance).to.be.bignumber.equal(mintAmount)

    // upgrade to V2 of token contract
    tokenV2Impl = await ProxiedTokenV2.new()
    proxy.upgradeTo(tokenV2Impl.address)

    // ensure token balances survived upgrade
    ownerBalance = await token.balanceOf(tokenOwner, {from: regularUser1})
    expect(ownerBalance).to.be.bignumber.equal(startSupply)
    user1Balance = await token.balanceOf(regularUser1, {from: regularUser1})
    expect(user1Balance).to.be.bignumber.equal(mintAmount)

    // use token v2 via proxy to inflate token owner's tokens
    const inflatedOwnerBalance = new BigNumber('1030015000000000000000000000')
    tokenV2 = await ProxiedTokenV2.at(proxy.address)
    await tokenV2.inflateOwnerTokens({from: tokenOwner})
    ownerBalance = await token.balanceOf(tokenOwner, {from: regularUser1})
    expect(ownerBalance).to.be.bignumber.equal(inflatedOwnerBalance)
    user1Balance = await token.balanceOf(regularUser1, {from: regularUser1})
    expect(user1Balance).to.be.bignumber.equal(mintAmount)

    // transfer all tokens from regularUser1 to regularUser2, using an API that
    // existed in the token V1 code)
    tokenV2.transfer(regularUser2, mintAmount, {from: regularUser1})
    user1Balance = await token.balanceOf(regularUser1, {from: regularUser1})
    expect(user1Balance).to.be.bignumber.equal(mintAmount)
    let user2Balance = await token.balanceOf(regularUser2, {from: regularUser2})
    expect(user2Balance).to.be.bignumber.equal(mintAmount)
  })
})
