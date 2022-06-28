// Get funds from users
// Withraw funds
// set a minimium funding valuse in usd
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "./PriceConverter.sol";

// custom error 1
error FundMe__NotOwner();

/** @title  A contract for crowd funding
 * @author Farayibi Mathhew
 * @notice This contract is to demo a sample funding contract
 * @dev This implement price feeds as our library
 */
contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMIUM_USD = 50 * 10**18;

    address[] private s_funders;

    mapping(address => uint256) private s_addressToAmountFunded;

    address private immutable i_amOwner;

    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner() {
        // require(msg.sender == i_amOwner, "Sender is not owner");
        // Custom error 1
        if (msg.sender != i_amOwner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeedAddress) {
        i_amOwner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    /** @notice This function funds this contract
     * @dev This implement price feeds as our library
     */

    function fund() public payable {
        //  set minimium fund amount in usd
        // 1. How do we send eth to this account
        // msg.value :- value of the sender

        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMIUM_USD,
            "Didn't send enough"
        ); // 1eth = 1e18
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
        // What is reverting??
        // undo any action before, and send remaining ggas fees
    }

    function withraw() public onlyOwner {
        // for(starting index, ending index, step amount) loop
        for (
            uint256 foundersIndex = 0;
            foundersIndex < s_funders.length;
            foundersIndex++
        ) {
            address funder = s_funders[foundersIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        // resetting array
        s_funders = new address[](0);

        // actually withdraw fund (3 ways)
        // 1. transfer
        // Note1: msg.sender is of the type address
        // Note2: payable(msg.sender) is of the type payable address
        // payable(msg.sender).transfer(address(this).balance);
        // 2. send
        // bool sentSucess = payable(msg.sender).send(address(this).balance);
        // require(sentSucess, "send failed");
        // 3. call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call Failed");
    }

    function cheaperWithdraw() public payable onlyOwner{
        address[] memory funders = s_funders;
        for(uint256 fundersIndex = 0; fundersIndex < funders.length; fundersIndex++){
            address funder = funders[fundersIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call Failed");
    }

    function getOwner() public view returns(address){
        return i_amOwner;
    }

    function getFunders(uint256 index) public view returns(address){
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder) public view returns(uint256){
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns(AggregatorV3Interface){
        return s_priceFeed;
    }
}
