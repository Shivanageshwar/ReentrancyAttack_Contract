// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error NoBalance();
error ZeroValue();

contract EtherBank is ReentrancyGuard {
    using Address for address payable;

    // user balances (private; read via getter below)
    mapping(address => uint256) private balances;

    // Events
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // Deposit ETH to caller's balance
    function deposit() external payable {
        if (msg.value == 0) revert ZeroValue();
        // single storage write (adds to existing)
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw entire balance. Safe: update state before interaction.
    function withdraw() external nonReentrant {
        uint256 bal = balances[msg.sender];
        if (bal == 0) revert NoBalance();

        // EFFECT: clear storage first (gas-friendly)
        delete balances[msg.sender];

        // INTERACTION: external call last
        payable(msg.sender).sendValue(bal);

        emit Withdraw(msg.sender, bal);
    }

    // Get contract total ETH
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Get user's balance
    function getUserBalance(address user) external view returns (uint256) {
        return balances[user];
    }
}
