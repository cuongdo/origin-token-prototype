pragma solidity ^0.4.23;

import "./StandardToken.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
 
// TODO(cuongdo): port Ownable to EternalStorage
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  // Migrated to EternalStorage
  //bool public mintingFinished = false;
  
  // EternalStorage keys
  bytes32 constant mintingFinishedKey = keccak256("token.mintingfinished");

  modifier canMint() {
    require(!mintingFinished());
    _;
  }
  
  function mintingFinished() public view returns (bool) {
    return es.getBool(mintingFinishedKey);
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {
    // was: totalSupply_ = totalSupply_.add(_amount);
    es.inc(totalSupplyKey, _amount);
    // was: balances[_to] = balances[_to].add(_amount)
    es.inc(balanceOfKey(_to), _amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    // was: mintingFinished = true;
    es.setBool(mintingFinishedKey, true);
    emit MintFinished();
    return true;
  }
}
