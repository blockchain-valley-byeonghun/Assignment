// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract EtherBankSG is ReentrancyGuard {
    using Address for address payable;

    // keeps track of all savings account balances
    mapping(address => uint) public balances;

    // deposit funds into the sender's account
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        console.log("Bank balance: ", address(this).balance);
    }

    // withdraw all funds from the user's account

    // nonReentrant - 실행된 순간 enter가 된다
    // nonReentranceAfter - 다 끝나야 _NOT_ENTERED가 된다
    function withdraw() external nonReentrant {
        require(
            balances[msg.sender] > 0,
            "Withdrawl amount exceeds available balance."
        );

        console.log("");
        console.log("EtherBank balance: ", address(this).balance);
        console.log("Attacker balance: ", balances[msg.sender]);
        console.log("");

        (bool success, ) = payable(msg.sender).call{
            value: balances[msg.sender]
        }("");
        require(success, "Transfer failed.");
        balances[msg.sender] = 0;
    }

    // check the total balance of the EtherBank contract
    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}
