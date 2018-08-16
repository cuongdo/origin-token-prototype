const SimpleDSToken = artifacts.require('SimpleDSToken') // ds-token
const SimpleOZToken = artifacts.require('SimpleOZToken') // OpenZeppelin

const BigNumber = web3.BigNumber
var chai = require('chai')
chai.use(require('chai-bignumber')(BigNumber))
var expect = chai.expect

// https://github.com/ethereum/web3.js/issues/1023#issuecomment-350791050
//
// TODO: understand this code :-)
const Promisify = (inner) =>
  new Promise((resolve, reject) =>
    inner((err, res) => {
      if (err) {
        reject(err);
      } else {
        resolve(res);
      }
    })
  );

contract('PauseAndMintUpgrade', ([owner, account1, account2]) => {
  it('can transfer over balances', async function() {
    const initialSupply = 100
    const transferAmount = 9
    const approval1 = 13
    const approval2 = transferAmount

    // -----------------------------------------------------------------------
    // create OpenZeppelin token contract
    //------------------------------------------------------------------------

    // deploy OpenZeppelin-based trivial token
    const oldToken = await SimpleOZToken.new(initialSupply, {from: owner})

    // -----------------------------------------------------------------------
    // perform operations that will be migrated later
    //------------------------------------------------------------------------
    await oldToken.transfer(account1, transferAmount)
    expect(await oldToken.balanceOf(owner)).to.be.bignumber.equal(initialSupply - transferAmount)
    expect(await oldToken.balanceOf(account1)).to.be.bignumber.equal(transferAmount)

    await oldToken.approve(account1, approval1, {from: owner})
    await oldToken.approve(account2, approval2, {from: account1})
    expect(await oldToken.allowance(owner, account1)).to.be.bignumber.equal(approval1)
    expect(await oldToken.allowance(account1, account2)).to.be.bignumber.equal(approval2)

    // -----------------------------------------------------------------------
    // pause token
    //------------------------------------------------------------------------

    await oldToken.pause()
    assert.isTrue(await oldToken.paused())

    // -----------------------------------------------------------------------
    // create new DSToken contract
    //------------------------------------------------------------------------

    const newToken = await SimpleDSToken.new(0)

    // -----------------------------------------------------------------------
    // migrate balances to new token contract
    //------------------------------------------------------------------------

    // grab all accounts from Transfer events
    let accounts = new Set()
    const transferEvent = oldToken.Transfer({}, {fromBlock: 0, toBlock: 'latest'})
    const transferEvents = await Promisify(cb => transferEvent.get(cb))
    transferEvents.forEach(event => {
      accounts.add(event.args['from'])
      accounts.add(event.args['to'])
    })

    // create new contracts and mint tokens in each account that had tokens in
    // the old contract
    await Promise.all([...accounts].map(async account => {
      const amount = await oldToken.balanceOf(account)
      if (amount > 0) {
        await newToken.mint(account, amount)
        console.log('minted', amount.toNumber(), 'tokens in account', account)
      }
    }))

    // verify that balances match total supply match between the two contracts
    await Promise.all([...accounts].map(async account => {
      const oldBalance = await oldToken.balanceOf(account)
      const newBalance = await newToken.balanceOf(account)
      expect(oldBalance).to.be.bignumber.equal(newBalance)
    }))
    const oldTotalSupply = await oldToken.totalSupply()
    const newTotalSupply = await newToken.totalSupply()
    expect(oldTotalSupply).to.be.bignumber.equal(newTotalSupply)

    // -----------------------------------------------------------------------
    // migrate approvals
    //------------------------------------------------------------------------

    // get all approver -> spender pairs
    let approvals = new Set()
    const approvalEvent = oldToken.Approval({}, {fromBlock: 0, toBlock: 'latest'})
    const approvalEvents = await Promisify(cb => approvalEvent.get(cb))
    approvalEvents.forEach(event => {
      // TODO: there must be a better way to create a Set of unique objects
      approvals.add(event.args['owner'] + ',' + event.args['spender'])
    })

    // migrate approvals using new, custom function approveFrom()
    await Promise.all([...approvals].map(async approval => {
      const [owner, spender] = approval.split(',')
      const allowance = await oldToken.allowance(owner, spender)
      if (allowance > 0) {
        await newToken.approveFrom(owner, spender, allowance)
        console.log('migrated approval of', allowance.toNumber(), 'tokens from', owner, 'to', spender)
      }
    }))

    // verify migrated approvals
    await Promise.all([...approvals].map(async approval => {
      const [owner, spender] = approval.split(',')
      const oldApproval = await oldToken.allowance(owner, spender)
      const newApproval = await newToken.allowance(owner, spender)
      expect(oldApproval).to.be.bignumber.equal(newApproval)
    }))

    // -----------------------------------------------------------------------
    // do not allow any more calls to approveFrom, for safety
    //------------------------------------------------------------------------
    await newToken.finishMigration()
  })
})
