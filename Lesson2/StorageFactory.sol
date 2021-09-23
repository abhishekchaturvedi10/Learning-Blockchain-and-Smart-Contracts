// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "../Lesson1/SimpleStorage.sol";

contract StorageFactory is SimpleStorage { // Inheritance
    
    SimpleStorage[] public simpleStorageArray;
    
    // Function to deploy SimpleStorage contract from StorageFactory contract

    function createSimpleStorageContract() public {
        
        SimpleStorage simpleStorage = new SimpleStorage();
        
        simpleStorageArray.push(simpleStorage);
    }
    
    function sfStore(uint256 _simpleStorageIndex, uint256 _simpleStorageNumber) public {
         
        // Two things required to interact with a contract
        // Address
        // ABI = Application Binary Interface
    
        SimpleStorage(address(simpleStorageArray[_simpleStorageIndex])).store(_simpleStorageNumber);
    }
    
    function sfGet(uint256 _simpleStorageIndex) public view returns(uint256) {
        
        return SimpleStorage(address(simpleStorageArray[_simpleStorageIndex])).retrieve();
    }
}