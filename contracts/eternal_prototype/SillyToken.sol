pragma solidity 0.4.24;

import "./StandardBurnableToken.sol";
import "./MintableToken.sol";

contract SillyToken is StandardBurnableToken, MintableToken {
  string public constant name = "ProxiedToken"; // solium-disable-line uppercase
  string public constant symbol = "PRX"; // solium-disable-line uppercase
  uint8 public constant decimals = 18; // solium-disable-line uppercase
  uint256 public constant INITIAL_SUPPLY = 1e9 * (10 ** uint256(decimals));
    
  constructor(EternalStorage es_) public BasicToken(es_) {
    // TODO(cuongdo): port to EternalStorage
    owner = msg.sender;
    // was: totalSupply_ = INITIAL_SUPPLY;
    es.setUint(totalSupplyKey, INITIAL_SUPPLY);
    //was: balances[msg.sender] = INITIAL_SUPPLY;
    es.setUint(balanceOfKey(msg.sender), INITIAL_SUPPLY);
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }
}