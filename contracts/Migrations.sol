//SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

contract Migrations {
    address public owner;
    uint256 public lastCompletedMigration;

    constructor() {
        owner = msg.sender;
    }

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function setCompleted(uint256 completed) external restricted {
        lastCompletedMigration = completed;
    }

    function upgrade(address newAddress) external restricted {
        Migrations upgraded = Migrations(newAddress);
        upgraded.setCompleted(lastCompletedMigration);
    }
}
