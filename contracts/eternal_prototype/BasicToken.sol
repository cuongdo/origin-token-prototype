pragma solidity ^0.4.23;


import "./ERC20Basic.sol";
import "./EternalStorage.sol";
import "./EternalStorageLib.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  EternalStorage es;
  using EternalStorageLib for EternalStorage;
  
  // moved to EternalStorage
  // mapping(address => uint256) balances;
  //
  // uint256 totalSupply_;
  
  // EternalStorage keys
  bytes32 public constant totalSupplyKey = keccak256("token.totalSupply");
  function balanceOfKey(address _owner) public pure returns (bytes32) {
    return keccak256(abi.encodePacked("token.balances.", _owner));
  }

  constructor(EternalStorage es_) public {
    es = es_;
  }

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return es.getUint(totalSupplyKey);
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balanceOf(msg.sender));

    // was: balances[msg.sender] = balances[msg.sender].sub(_value);
    es.dec(balanceOfKey(msg.sender), _value);
    // was: balances[_to] = balances[_to].add(_value);
    es.inc(balanceOfKey(_to), _value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    // was: return balances[_owner];
    return es.getUint(balanceOfKey(_owner));
  }
 
}
