pragma solidity 0.4.24;

import "./EternalStorage.sol";

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

// Convenience functions that don't belong in EternalStorage contract because
// they aren't core to its operation.
library EternalStorageLib {
  using SafeMath for uint;
  
  function inc(EternalStorage es, bytes32 key, uint n) public {
    es.setUint(key, es.getUint(key).add(n));
  }
  
  function dec(EternalStorage es, bytes32 key, uint n) public {
    es.setUint(key, es.getUint(key).sub(n));
  }
}