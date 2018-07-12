var OriginToken = artifacts.require("OriginToken");

contract('OriginToken', accounts => {
  const startSupply = 1e9 * 1e18 // TODO(cuongdo): make mock that supports passing this in
  var token
  var owner

  beforeEach(async () => {
    token = await OriginToken.new()
    owner = accounts[0]
  })

  it("has the correct name", async function() {
    let name = await token.name()
    assert.strictEqual(name, "OriginToken")
  })

  it("should put 1,000,000,000 Origin token in the first account", async function() {
    let balance = await token.balanceOf(owner)
    assert.strictEqual(balance.toNumber(), startSupply)
  })

  it("should not transfer tokens to non-owner accounts", async function() {
    for (let account of accounts) {
      if (account === owner) {
        continue
      }
      let balance = await token.balanceOf(account)
      assert.strictEqual(balance.toNumber(), 0)
    }
  })

  // BIG TODO(cuongdo): figure out how to use Zeppelin's tests from our tests

  it("should burn 50,000 tokens", async function() {
    const burnAmount = 50000 * 1e18
    await token.burn(burnAmount)
    let balance = await token.balanceOf(owner)
    assert.strictEqual(balance.toNumber(), startSupply - burnAmount)
  })

  it("should mint 50,000 tokens and grant them to account 1", async function() {
    const beneficiary = accounts[1]
    const mintAmount = 50000 * 1e18
    await token.mint(beneficiary, mintAmount)
    let balance = await token.balanceOf(beneficiary)
    assert.strictEqual(balance.toNumber(), mintAmount)
  })
})
