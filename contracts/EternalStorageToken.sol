pragma solidity 0.4.24;

// This file has only been tested in Remix. Not hooked up to Truffle tests.

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

// ----------------------------------------------------------------------------
// copied-and pasted code
// ----------------------------------------------------------------------------


// based on: https://github.com/rocket-pool/rocketpool/blob/master/contracts/RocketStorage.sol
// note that this has no security model at all! (no need for a prototype)
//
/// @title The primary persistent storage for Rocket Pool
/// @author David Rugendyke
contract EternalStorage {

    /**** Storage Types *******/

    mapping(bytes32 => uint256)    private uIntStorage;
    mapping(bytes32 => string)     private stringStorage;
    mapping(bytes32 => address)    private addressStorage;
    mapping(bytes32 => bytes)      private bytesStorage;
    mapping(bytes32 => bool)       private boolStorage;
    mapping(bytes32 => int256)     private intStorage;


    /// @dev constructor
    constructor() public {
        // Set the main owner upon deployment
        boolStorage[keccak256("access.role", "owner", msg.sender)] = true;
    }


    /**** Get Methods ***********/
   
    /// @param _key The key for the record
    function getAddress(bytes32 _key) external view returns (address) {
        return addressStorage[_key];
    }

    /// @param _key The key for the record
    function getUint(bytes32 _key) external view returns (uint) {
        return uIntStorage[_key];
    }

    /// @param _key The key for the record
    function getString(bytes32 _key) external view returns (string) {
        return stringStorage[_key];
    }

    /// @param _key The key for the record
    function getBytes(bytes32 _key) external view returns (bytes) {
        return bytesStorage[_key];
    }

    /// @param _key The key for the record
    function getBool(bytes32 _key) external view returns (bool) {
        return boolStorage[_key];
    }

    /// @param _key The key for the record
    function getInt(bytes32 _key) external view returns (int) {
        return intStorage[_key];
    }

    /**** Set Methods ***********/

    /// @param _key The key for the record
    function setAddress(bytes32 _key, address _value) external {
        addressStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setUint(bytes32 _key, uint _value) external {
        uIntStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setString(bytes32 _key, string _value) external {
        stringStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setBytes(bytes32 _key, bytes _value) external {
        bytesStorage[_key] = _value;
    }
    
    /// @param _key The key for the record
    function setBool(bytes32 _key, bool _value) external {
        boolStorage[_key] = _value;
    }
    
    /// @param _key The key for the record
    function setInt(bytes32 _key, int _value) external {
        intStorage[_key] = _value;
    }

    /**** Delete Methods ***********/
    
    /// @param _key The key for the record
    function deleteAddress(bytes32 _key) external {
        delete addressStorage[_key];
    }

    /// @param _key The key for the record
    function deleteUint(bytes32 _key) external {
        delete uIntStorage[_key];
    }

    /// @param _key The key for the record
    function deleteString(bytes32 _key) external {
        delete stringStorage[_key];
    }

    /// @param _key The key for the record
    function deleteBytes(bytes32 _key) external {
        delete bytesStorage[_key];
    }
    
    /// @param _key The key for the record
    function deleteBool(bytes32 _key) external {
        delete boolStorage[_key];
    }
    
    /// @param _key The key for the record
    function deleteInt(bytes32 _key) external {
        delete intStorage[_key];
    }
}

// ----------------------------------------------------------------------------
// code adapted for EternalStorage
// ----------------------------------------------------------------------------

// source: https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/ERC20Basic.sol
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * Based on: https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/BasicToken.sol
 * 
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  // Original state variables:
  // mapping(address => uint256) balances;
  // uint256 totalSupply_;
  
  // keys for EternalStorage
  bytes32 constant TOTAL_SUPPLY_KEY = keccak256("basictoken.totalSupply");
  string constant BALANCES_PREFIX = "basictoken.balances.";
  
  EternalStorage eternalStorage;
  
  constructor(address eternalStorage_) public {
      eternalStorage = EternalStorage(eternalStorage_);
  }
  
  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return eternalStorage.getUint(TOTAL_SUPPLY_KEY);
  }
  
  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    bytes32 senderBalanceKey = keccak256(BALANCES_PREFIX, msg.sender);
    bytes32 toBalanceKey = keccak256(BALANCES_PREFIX, _to);
      
    require(_value <= balanceOf(msg.sender), "insufficient balance");
    require(_to != address(0), "cannot send to address 0");

    eternalStorage.setUint(senderBalanceKey, balanceOf(msg.sender).sub(_value));
    eternalStorage.setUint(toBalanceKey, balanceOf(_to).add(_value));
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return eternalStorage.getUint(keccak256(BALANCES_PREFIX, _owner));
  }
}

// a silly token example backed by EternalStorage
contract SillyEternalStorageToken is BasicToken {
  bytes32 constant OWNER_KEY = keccak256("basictoken.owner");
  constructor(address eternalStorage_, uint initialSupply) BasicToken(eternalStorage_) public {
      eternalStorage.setUint(TOTAL_SUPPLY_KEY, 1000);
      eternalStorage.setAddress(OWNER_KEY, msg.sender);
      eternalStorage.setUint(keccak256(BALANCES_PREFIX, msg.sender), initialSupply);
  }
}