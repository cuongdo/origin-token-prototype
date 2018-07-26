pragma solidity ^0.4.23;

import "./BasicToken.sol";
import "./ERC20.sol";


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {
  // moved to EternalStorage
  //mapping (address => mapping (address => uint256)) internal allowed;
  
  // EternalStorage keys
  // NOTE(cuongdo): here's a tradeoff of using EternalStorage: we have to
  // flatten what's naturally a nested data structure
  function allowedKey(
    address _from,
    address _to
  ) 
    public
    pure
    returns (bytes32)
  {
    return keccak256(abi.encodePacked("token.allowed",_from, _to));  
  }
  
  function allowed(address _from, address _to) internal view returns (uint256) {
    return es.getUint(allowedKey(_from, _to));
  }
  
  function setAllowed(address _from, address _to, uint256 _value) internal {
    es.setUint(allowedKey(_from, _to), _value);
  }


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    // was: require(_value <= balances[_from]);
    require(_value <= balanceOf(_from));
    // was: require(_value <= allowed[_from][msg.sender]);
    require(_value <= allowed(_from, msg.sender));

    // was: balances[_from] = balances[_from].sub(_value);
    es.dec(balanceOfKey(_from), _value);
    // was: balances[_to] = balances[_to].add(_value);
    es.dec(balanceOfKey(_to), _value);
    // was: allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    es.dec(allowedKey(_from, msg.sender), _value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    // was: allowed[msg.sender][_spender] = _value;
    es.setUint(allowedKey(msg.sender, _spender), _value);
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    // was: return allowed[_owner][_spender];
    return es.getUint(allowedKey(_owner, _spender));
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    // was:
    //allowed[msg.sender][_spender] = (
    //  allowed[msg.sender][_spender].add(_addedValue));
    es.inc(allowedKey(msg.sender, _spender), _addedValue);
    // was: emit Approval(msg.sender, _spender, allowed([msg.sender][_spender]);
    emit Approval(msg.sender, _spender, allowed(msg.sender, _spender));
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    // was: uint oldValue = allowed[msg.sender][_spender];
    uint oldValue = allowed(msg.sender, _spender);
    if (_subtractedValue > oldValue) {
      //was: allowed[msg.sender][_spender] = 0;
      setAllowed(msg.sender, _spender, 0);
    } else {
      //was: allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
      setAllowed(msg.sender, _spender, _subtractedValue);
    }
    // was: emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    emit Approval(msg.sender, _spender, allowed(msg.sender, _spender));
    return true;
  }

}
