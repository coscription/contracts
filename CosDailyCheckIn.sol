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

    function dailyCheckIn() external {
        uint256 day = block.timestamp / 86400;
        uint256 lastTime = dailyCheckTimeMap[msg.sender];
        require(day > lastTime, "daily check time has not arrived");
        dailyCheckTimeMap[msg.sender] = day;
        userAccumulativeCheckIn[msg.sender] += 1;

        (bool success, ) = payable(msg.sender).call{value: txFee}("");
        require(success, "NOT ENOUGH ETHER TO SEND!");
        emit TxFeeSend(msg.sender, txFee, block.timestamp);

        emit DailyCheckIn(
            msg.sender,
            block.timestamp,
            dailyCheckTimeMap[msg.sender]
        );
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

    function getUserNextCheckInTime(
        address user
    ) external view returns (uint256) {
        return dailyCheckTimeMap[user];
    }

    function getUserAccumulativeCheckIn(
        address user
    ) external view returns (uint256) {
        return userAccumulativeCheckIn[user];
    }
}
