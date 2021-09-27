// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

// Importing interface from https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol
// import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

// interfaces complie down to an ABI
// ABI is needed to interact with a contract
// ABI tells solidity how it can interact with another contract

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract FundMe {
    // In solidity <0.8 overflow wraps around. Eg - int8 = 255 + 100; => int8 = 99
    // In solidity >=0.8 overflows are not required to be handled explicitly

    using SafeMathChainlink for uint256; // automatically checks for overflow

    // Map to store the amount corresponding to the sender's address
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;

    AggregatorV3Interface public priceFeed;

    address[] public funders;

    constructor(address _priceFeed) public {
        // Accessing interface functions at the address _priceFeed
        priceFeed = AggregatorV3Interface(_priceFeed);

        // Stores the address of the sender's account of this contract
        owner = msg.sender;
    }

    // paybale means the function is used to pay
    function fund() public payable {
        // Min amount of monet that can be accepted (50$)
        uint256 minimumUSD = 50 * 10**18;

        // Evaluates the condition before the contract can go forward if condition fails then reverts back with a message
        require(
            minimumUSD <= getConversionRate(msg.value),
            "You need to spend more ETH!"
        );

        // msg.sender and msg.value are keywords associated with a contract
        addressToAmountFunded[msg.sender] += msg.value;

        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();

        return uint256(answer * 10000000000);
        // Bringing down the rate to the wei level which is the smallest unit of eth measurement
        // By default answer had 8 decimals so multiplying by 10^10 gives 18 decimal places
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256)
    {
        uint256 ethPrice = getPrice();

        uint256 priceInUSD = (ethPrice * ethAmount) / 1000000000000000000;

        return priceInUSD; //1 eth = 2900 (rounded) 25/09/21
    }

    function getEntranceFee() public view returns (uint256) {
        // mimimumUSD
        uint256 mimimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return ((mimimumUSD * precision) / price);
    }

    modifier onlyOwner() {
        // Only the admin/owner of this contract can withdraw the money
        require(
            msg.sender == owner,
            "You cannot withdraw since you are not the owner!"
        );

        _;
    }

    function withdraw() public payable onlyOwner {
        // Send msg.sender/owner all the money in this contract back
        // this keyword refers to the contract we are currently in
        msg.sender.transfer(address(this).balance);

        // Set the amount sent by of all the funders to 0
        for (uint256 i = 0; i < funders.length; i++) {
            addressToAmountFunded[funders[i]] = 0;
        }

        // Reset the fuunders array
        funders = new address[](0);
    }
}
