pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardBurnableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

// the following is for Remix testing
import "zos-lib/contracts/migrations/Initializable.sol";
import "zos-lib/contracts/upgradeability/AdminUpgradeabilityProxy.sol";

contract OriginToken is Initializable, StandardBurnableToken, MintableToken {
  string public constant name = "OriginToken"; // solium-disable-line uppercase
  string public constant symbol = "OGN"; // solium-disable-line uppercase
  uint8 public constant decimals = 18; // solium-disable-line uppercase

  uint256 public constant INITIAL_SUPPLY = 1e9 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function initialize() isInitializer payable public {
    // we need to set this explicitly, because Ownable's constructor isn't
    // called with the proxy's address.
    //
    // TODO(cuongdo): audit code for other constructors. yikes!
    owner = msg.sender;
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }
}

// throwaway code to exercise adding functionality through a contract upgrade
contract OriginTokenV2 is OriginToken {
  event Debug(uint256 i);
  using SafeMath for uint256;

  uint256 public constant INFLATION_PERCENT = 3;

  // This is just a proof of concept to test upgradability. This is not
  // necessarily indicative of anything that may be implemented in the future.
  //
  // NOTE: there is no way to iterate over a mapping, so we'd need to either add
  // an array of account holders or rely on something else like logs to
  // distribute inflation across all token holders.
  function inflateOwnerTokens() public onlyOwner {
    uint256 newTokens = totalSupply_.mul(INFLATION_PERCENT).div(100);
    mint(owner, newTokens);
  }
}
