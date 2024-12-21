// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for cross-chain bridge
interface IBridge {
    function transfer(address from, address to, uint256 amount, string calldata destinationChain) external returns (bool);
}

contract EducationFunding {

    address public owner;
    uint256 public totalFunds;
    mapping(address => uint256) public donations;

    IBridge public bridge; // Cross-chain bridge interface

    // Events for logging actions
    event DonationReceived(address indexed donor, uint256 amount);
    event FundTransferred(address indexed recipient, uint256 amount, string destinationChain);
    event FundsWithdrawn(address indexed recipient, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    // Constructor to initialize the contract with bridge address
    constructor(address _bridgeAddress) {
        owner = msg.sender;
        bridge = IBridge(_bridgeAddress);
    }

    // Function for users to donate funds
    function donate() external payable {
        require(msg.value > 0, "Donation must be greater than zero.");
        donations[msg.sender] += msg.value;
        totalFunds += msg.value;
        emit DonationReceived(msg.sender, msg.value);
    }

    // Function to transfer funds to a recipient on another blockchain
    function transferFunds(address recipient, uint256 amount, string calldata destinationChain) external onlyOwner {
        require(amount <= totalFunds, "Insufficient funds.");
        totalFunds -= amount;
        emit FundTransferred(recipient, amount, destinationChain);

        // Cross-chain transfer via the bridge
        require(bridge.transfer(address(this), recipient, amount, destinationChain), "Cross-chain transfer failed.");
    }

    // Function to withdraw funds for educational purposes
    function withdrawFunds(uint256 amount) external onlyOwner {
        require(amount <= totalFunds, "Insufficient funds.");
        payable(owner).transfer(amount);
        totalFunds -= amount;
        emit FundsWithdrawn(owner, amount);
    }

    // Function to get the current donation balance of the sender
    function getDonationBalance() external view returns (uint256) {
        return donations[msg.sender];
    }
}
