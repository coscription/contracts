pragma solidity 0.8.14;

import "forge-std/Test.sol";
import "../src/CosDailyCheckIn.sol";

contract CosDailyCheckInTest is Test {
    CosDailyCheckIn public cosDailyCheckIn;

    function setUp() public {
        // owner
        address someUser = vm.addr(1);
        vm.startPrank(someUser);
        cosDailyCheckIn = new CosDailyCheckIn();
        // set block current timestamp
        vm.warp(1641070800);
        emit log_uint(block.timestamp);
        // send ether to contract
        vm.deal(address(cosDailyCheckIn), 10 ether);
        assertEq(address(cosDailyCheckIn).balance, 10 ether);
        vm.stopPrank();
    }

    function testDailyCheckIn() public {
        vm.startPrank(vm.addr(2));
        cosDailyCheckIn.dailyCheckIn();
        vm.stopPrank();
    }

    function testWithdrawAllTxFee() public {
        vm.startPrank(vm.addr(1));
        cosDailyCheckIn.withdrawAllTxFee();
        vm.stopPrank();
    }

    function testFailWithdrawAllTxFeeAsNotOwner() public {
        vm.startPrank(vm.addr(2));
        cosDailyCheckIn.withdrawAllTxFee();
        vm.stopPrank();
    }

    function testChangeTxFee() public {
        vm.startPrank(vm.addr(1));
        cosDailyCheckIn.changeTxFee(2000);
        vm.stopPrank();
    }

    function testFailChangeTxFeeAsNotOwner() public {
        vm.startPrank(vm.addr(2));
        cosDailyCheckIn.changeTxFee(2000);
        vm.stopPrank();
    }

    function testClearCheckIn() public {
        vm.startPrank(vm.addr(1));
        cosDailyCheckIn.clearCheckIn(vm.addr(1));
        vm.stopPrank();
    }

     function testFailClearCheckInAsNotOwner() public {
        vm.startPrank(vm.addr(2));
        cosDailyCheckIn.clearCheckIn(vm.addr(1));
        vm.stopPrank();
    }
}
