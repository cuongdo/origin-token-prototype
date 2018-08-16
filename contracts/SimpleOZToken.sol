pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol";

// Trivial token based on OpenZeppelin's ERC20 code
contract SimpleOZToken is PausableToken {
  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor(uint256 initialSupply) payable public {
    owner = msg.sender;
    totalSupply_ = initialSupply;
    balances[msg.sender] = initialSupply;
    emit Transfer(address(0), msg.sender, initialSupply);
  }
}