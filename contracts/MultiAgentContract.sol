// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOracle {
    function getGlobalState() external view returns (uint256);  // 获取全局状态，如交通流畅度、资源利用率等
}

contract MultiAgentContract {
    address public owner;
    IOracle public oracle;  // oracle 合约地址，用于提供全局数据
    mapping(address => uint256) public agentRewards;  // 存储每个代理的奖励
    mapping(address => bool) public agentBehaviors;  // 存储代理是否遵守行为规则

    event RewardPaid(address indexed agent, uint256 reward);
    event RewardUpdated(address indexed agent, uint256 reward);
    event BehaviorPunished(address indexed agent, uint256 punishment);

    constructor(address _oracle) {
        owner = msg.sender;  // 合约的创建者为管理员
        oracle = IOracle(_oracle);  // 传入外部 oracle 合约地址
    }

    // 只能管理员调用，用于更新代理的奖励
    function updateReward(address agent, uint256 reward) public {
        require(msg.sender == owner, "Only owner can update reward.");
        agentRewards[agent] = reward;
        emit RewardUpdated(agent, reward);
    }

    // 代理遵守行为规则时，调用此函数来支付奖励
    function payReward(address agent) public {
        uint256 reward = agentRewards[agent];
        require(reward > 0, "No reward to pay.");

        uint256 globalState = oracle.getGlobalState(); 
        uint256 adjustedReward = reward * globalState / 100;

        uint256 maxReward = 100000000000000000;  // 0.1 ETH
        if (adjustedReward > maxReward) {
            adjustedReward = maxReward;
        }

        emit LogRewardDetails(reward, globalState, adjustedReward);

        require(address(this).balance >= adjustedReward, "Contract doesn't have enough funds to pay the reward.");

        if (agentBehaviors[agent]) {
            payable(agent).transfer(adjustedReward); 
            emit RewardPaid(agent, adjustedReward);
            agentRewards[agent] = 0; 
        } else {
            punishBehavior(agent);  // punishment
        }
    }



    // Event to log reward details for debugging
    event LogRewardDetails(uint256 reward, uint256 globalState, uint256 adjustedReward);




    // 更新代理行为，合规时返回 true，违规时返回 false
    function setAgentBehavior(address agent, bool isCompliant) public {
        require(msg.sender == owner, "Only owner can update behavior.");
        agentBehaviors[agent] = isCompliant;
    }

    // 惩罚违规行为
    function punishBehavior(address agent) internal {
        uint256 punishment = agentRewards[agent] / 2;  // 惩罚为奖励的一半
        payable(owner).transfer(punishment);  // 将惩罚金额转给管理员
        emit BehaviorPunished(agent, punishment);
        agentRewards[agent] = 0;
    }

    receive() external payable {}
}
