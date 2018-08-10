/* solium-disable security/no-block-members */

pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

// TODO: write informative comment here
contract TokenVesting is Ownable {
  using SafeMath for uint256;

  event Vested(uint256 amount);
  event Transferred(); // for transferring to new contract (for logic upgrade)
  event Revoked();

  struct VestingEvent {
    uint256 timestamp;
    uint256 amount;
  }
  
  // Total number of tokens vested so far
  uint256 public released;
  // Address to which tokens are transferred during vesting
  address public beneficiary;
  
  // Token contract for this grant.
  ERC20 public token;
  // UNIX timestamp of vesting cliff
  uint256 public cliff;
  // Number of tokens vested at cliff
  uint256 public cliffAmount;
  // UNIX timestamps for all vesting event. For example, monthly vesting would
  // be represented by a set of timestamps one month apart.
  uint256[] public vestingTimestamps;
  // Number of tokens to vest as each time in vestingTimestamps elapses.
  uint256 public vestingAmount;
  
  constructor(
    address _beneficiary,
    ERC20 _token,
    uint256 _cliff,
    uint256 _cliffAmount,
    uint256[] _vestingTimestamps,
    uint256 _vestingAmount
  )
    public
  {
    require(_vestingTimestamps[0] > _cliff);
    for (uint i = 1; i < _vestingTimestamps.length; i++) {
      require(_vestingTimestamps[i - 1] < _vestingTimestamps[i]);
    }
    owner = msg.sender;
    released = 0;
    beneficiary = _beneficiary;
    token = _token;
    cliff = _cliff;
    cliffAmount = _cliffAmount;
    vestingTimestamps = _vestingTimestamps;
    vestingAmount = _vestingAmount;
  }
  
  function totalGrant() public view returns (uint256) {
    return cliffAmount.add(vestingAmount.mul(vestingTimestamps.length));
  }
  
  function vest() public returns (uint256) {
    uint256 newlyVested = vested().sub(released);
    if (newlyVested == 0) {
      return 0;
    }
    require(token.transfer(beneficiary, newlyVested), "transfer failed");
    emit Vested(newlyVested);
    return newlyVested;
  }
  
  function vested() public view returns (uint256) {
    if (now < cliff) {
      return 0;
    }
    uint256 v = cliffAmount;
    for (uint i = 0; i < vestingTimestamps.length; i++) {
      if (now < vestingTimestamps[i]) {
        break;
      }
      v = v.add(vestingAmount);
    }
    return v;
  }
  
  // TODO: add revoke()
}
