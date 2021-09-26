// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract SimpleStorage {
    // bool favoriteBool = true;
    // string favoriteString = "Abhishek Chaturvedi";
    // int favoriteInt = -5;
    // address favoriteAddress = 0x1b397afD7d1eCe38Ee66008635FDa030338bdF56; // ethereum address
    // bytes32 favoriteBytes = "bytes"; // 32 bytes of memory

    // state changing functions appear in orange while non state changing ones appear in blue

    struct Person {
        string name; // it is at index 0 in struct
        uint256 favoriteNumber; // it is at index 1 in struct
    }

    // Person public person = Person({name: "Abhishek Chaturvedi", favoriteNumber: 10});

    uint256 favoriteNumber; // It will get intialised to 0 automatically

    function store(uint256 _favoriteNumber) public returns (uint256) {
        favoriteNumber = _favoriteNumber;
        return favoriteNumber;
    }

    // view and pure are non state changing functions hence do not cause a new transaction

    function retrieve() public view returns (uint256) {
        return favoriteNumber;
    }

    // function retrieve(uint256 favoriteNumber) public pure {
    //     favoriteNumber + favoriteNumber;
    // }

    Person[] public person; // Array of struct

    mapping(string => uint256) public nameToFavoriteNumber; // Map

    // memory keyword is used to store data only when function is executed and the value deletes after execution finishes
    // storage keyword is used to store data forever

    // string is an object of array of bytes so we need to add memory before it

    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        // person.push(Person({name: _name, favoriteNumber: _favoriteNumber}));
        person.push((Person(_name, _favoriteNumber)));
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }
}
