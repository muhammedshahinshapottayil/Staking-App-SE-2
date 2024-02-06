// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

error Err__Transfer__Failed();
error Err__Stake__Completed();
error Err__Withdraw__Failed(address,uint256 );
error Err__Threshold__and__Time__Failed(address,uint256 );
error Err__Participation__Time__Finished(address,uint256 );

contract Staker {

 event Stake(address,uint256);

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 hours;

  modifier notCompleted {
    if(exampleExternalContract.completed())
    revert Err__Stake__Completed();
    _;
  }

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
  function stake() notCompleted public payable {
    balances[msg.sender] = msg.value;
    emit Stake(msg.sender,msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
    function execute() public notCompleted {
      // if(address(this).balance < threshold)
      // revert Err__Transfer__Failed();
      // exampleExternalContract.complete{value: address(this).balance}();

      if(address(this).balance > threshold)
      exampleExternalContract.complete{value: address(this).balance}();

    }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public notCompleted {
   if((address(this).balance > threshold) || (timeLeft() > 0)) 
     revert Err__Threshold__and__Time__Failed(msg.sender,balances[msg.sender]);
    
    (bool success,) = payable(msg.sender).call{value:balances[msg.sender]}("");
    if (!success) 
     revert Err__Withdraw__Failed(msg.sender,balances[msg.sender]);
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
      return  block.timestamp >= deadline ? 0 : deadline - block.timestamp;
    }

  // Add the `receive()` special function that receives eth and calls stake()
      receive() external payable {
        stake();
      }
}
