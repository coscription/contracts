// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract CosDailyCheckIn is Ownable {
    mapping(address => uint256) internal dailyCheckTimeMap;
    mapping(address => uint256) internal userAccumulativeCheckIn;
    uint256 public txFee = 0.003 ether;

    event DailyCheckIn(
        address indexed,
        uint256 checkTime,
        uint256 nextCheckTime
    );

    event TxFeeChange(uint256 oldFee, uint256 newFee, uint256 changeTime);
    event TxFeeSend(address indexed user, uint256 txFee, uint256 time);
    event Charge(uint256 value, uint256 time);

    function dailyCheckIn() external {
        uint256 day = (block.timestamp + 8 * 3600) / 86400;
        uint256 lastTime = dailyCheckTimeMap[msg.sender];
        require(day > lastTime, "daily check time has not arrived");
        dailyCheckTimeMap[msg.sender] = day;
        ++userAccumulativeCheckIn[msg.sender];

        (bool success, ) = payable(msg.sender).call{value: txFee}("");
        require(success, "NOT ENOUGH ETHER TO SEND!");
        emit TxFeeSend(msg.sender, txFee, block.timestamp);

        emit DailyCheckIn(
            msg.sender,
            block.timestamp,
            (dailyCheckTimeMap[msg.sender] + 1) * 86400 - 8 * 3600
        );
    }

    receive() external payable {
        emit Charge(msg.value, block.timestamp);
    }

    function withdrawAllTxFee() external onlyOwner {
        uint256 txFee_ = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: txFee_}("");
        require(success, "NOT ENOUGH ETHER TO SEND!");
    }

    function changeTxFee(uint256 value) external onlyOwner {
        require(value > 0, "INVALID TX Fee");
        emit TxFeeChange(txFee, value, block.timestamp);
        txFee = value;
    }

    function clearCheckIn(address user) external onlyOwner {
        dailyCheckTimeMap[user] = block.timestamp;
        userAccumulativeCheckIn[user] = 0;
    }

    function getUserNextCheckInTime(
        address user
    ) external view returns (uint256) {
        if (dailyCheckTimeMap[user] == 0) {
            return block.timestamp;
        }
        return (dailyCheckTimeMap[user] + 1) * 86400 - 8 * 3600;
    }

    function getUserAccumulativeCheckIn(
        address user
    ) external view returns (uint256) {
        return userAccumulativeCheckIn[user];
    }
}
