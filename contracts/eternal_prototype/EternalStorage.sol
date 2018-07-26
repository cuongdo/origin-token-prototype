pragma solidity 0.4.24;


// @title Key/value storage contract
// @author Cuong Do
//
// Heavily based on Rocket Pool's RocketStorage.
contract EternalStorage {

    // Key/value mappings

    mapping(bytes32 => uint256)    private uIntStorage;
    mapping(bytes32 => string)     private stringStorage;
    mapping(bytes32 => address)    private addressStorage;
    mapping(bytes32 => bytes)      private bytesStorage;
    mapping(bytes32 => bool)       private boolStorage;
    mapping(bytes32 => int256)     private intStorage;


    /*** Modifiers ************/

    /// @dev Only allow access from the latest version of a contract in the Rocket Pool network after deployment
    modifier onlyLatestRocketNetworkContract() {
        // The owner and other contracts are only allowed to set the storage upon deployment to register the initial contracts/settings, afterwards their direct access is disabled
        if (boolStorage[keccak256("contract.storage.initialised")] == true) {
            // Make sure the access is permitted to only contracts in our Dapp
            require(addressStorage[keccak256(abi.encodePacked("contract.address", msg.sender))] != 0x0);
        }
        _;
    }


    /// @dev constructor
    constructor() public {
        // Set the main owner upon deployment
        boolStorage[keccak256(abi.encodePacked("access.role", "owner", msg.sender))] = true;
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
    // TODO(cuongdo): implement access control for setters & deleters

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