// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    // Mapping to track individual balances
    mapping(address => uint256) public balances;
    
    // Threshold for execution (0.5 ETH)
    uint256 public constant threshold = 0.5 ether;
    
    // Deadline for staking (72 hours from deployment)
    uint256 public deadline = block.timestamp + 72 hours;
    
    // Flag to track if execution has been called
    bool public executed;
    
    // Flag to allow withdrawals if threshold not met
    bool public openForWithdraw;
    
    // Events
    event Stake(address indexed staker, uint256 amount);
    event Execute(uint256 amount);
    event Withdraw(address indexed staker, uint256 amount);

    // Modifier to prevent actions after external contract is completed
    modifier notCompleted() {
        require(!exampleExternalContract.completed(), "External contract already completed");
        _;
    }

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
    function stake() public payable notCompleted {
        require(block.timestamp < deadline, "Staking period has ended");
        require(msg.value > 0, "Must send ETH to stake");
        
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
    function execute() public notCompleted {
        require(block.timestamp >= deadline, "Deadline has not passed yet");
        require(!executed, "Already executed");
        
        executed = true;
        
        if (address(this).balance >= threshold) {
            // Success state: threshold met, send funds to external contract
            exampleExternalContract.complete{value: address(this).balance}();
            emit Execute(address(this).balance);
        } else {
            // Withdraw state: threshold not met, allow withdrawals
            openForWithdraw = true;
        }
    }

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
    function withdraw() public notCompleted {
        require(openForWithdraw, "Withdrawals not open yet");
        require(balances[msg.sender] > 0, "No balance to withdraw");
        
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");
        
        emit Withdraw(msg.sender, amount);
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        // Only allow receiving ETH if external contract is not completed
        require(!exampleExternalContract.completed(), "External contract already completed");
        stake();
    }
}
