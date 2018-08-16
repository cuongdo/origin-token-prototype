pragma solidity ^0.4.23;

import "./ds-token/token.sol";

// trivial ds-token-based token
contract SimpleDSToken is DSToken("DST") {
  constructor(uint256 initialSupply) public {
    mint(initialSupply);
  }
  
  // -------------------------------------------------------------------------
  // NEW STUFF FOR MIGRATION
  //
  // Any functions that follow are protected by auth.
  // -------------------------------------------------------------------------
  
  bool internal migrationFinished = false;
  
  event MigrationFinished();
  modifier migration() {
    require(!migrationFinished);
    _;
  }
  
  // This is needed to migrate approvals from a previous token contract.
  // Because this should only be used for migrations, this is limited to the
  // owner.
  function approveFrom(
      address src,
      address dst,
      uint256 value
  )
    public
    auth
    migration
    returns (bool) 
  {
    _approvals[src][dst] = value;
    
    emit Approval(src, dst, value);
    
    return true;
  }
  
  function finishMigration() public auth {
    if (migrationFinished) {
      return;
    }
    migrationFinished = true;
    emit MigrationFinished();
  }
}