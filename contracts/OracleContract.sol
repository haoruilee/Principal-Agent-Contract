// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OracleContract {
    uint256 public globalState;  // 用来存储全局状态

    // 只有拥有者可以更新全局状态
    address public owner;

    event GlobalStateUpdated(uint256 newState);

    constructor() {
        owner = msg.sender;
    }

    // 更新全局状态
    function updateGlobalState(uint256 newState) external {
        require(msg.sender == owner, "Only owner can update the global state");
        globalState = newState;
        emit GlobalStateUpdated(newState);
    }

    // 返回全局状态
    function getGlobalState() external view returns (uint256) {
        return globalState;
    }
}
