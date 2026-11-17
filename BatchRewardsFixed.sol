// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BatchRewards {
    mapping(address => uint256) public balances;
    uint256 public constant MAX_RECEIVERS = 100;

    constructor() {
        balances[msg.sender] = 1000;
    }

    function batchTransfer(address[] calldata receivers, uint256 amount) external {
        require(receivers.length > 0, "Empty receivers");
        require(receivers.length <= MAX_RECEIVERS, "Too many receivers");

        uint256 total = receivers.length * amount;

        require(balances[msg.sender] >= total, "Insufficient balance");

        balances[msg.sender] -= total;

        for (uint256 i = 0; i < receivers.length; i++) {
            require(receivers[i] != address(0), "Zero address");

            balances[receivers[i]] += amount;
        }
    }
}
