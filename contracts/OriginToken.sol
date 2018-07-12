pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/StandardBurnableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

contract OriginToken is StandardBurnableToken, MintableToken {
  string public constant name = "OriginToken"; // solium-disable-line uppercase
  string public constant symbol = "OGN"; // solium-disable-line uppercase
  uint8 public constant decimals = 18; // solium-disable-line uppercase
  // TODO(cuongdo): what is the right number here? 18 is what Ethereum has

  // TODO(cuongdo): verify this initial supply
  uint256 public constant INITIAL_SUPPLY = 1e9 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }
}
