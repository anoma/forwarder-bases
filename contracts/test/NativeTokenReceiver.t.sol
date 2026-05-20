// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std-1.16.1/src/Test.sol";

import {INativeTokenReceiver} from "../src/interfaces/INativeTokenReceiver.sol";
import {NativeTokenReceiver} from "../src/NativeTokenReceiver.sol";

contract NativeTokenReceiverTest is Test, NativeTokenReceiver {
    function test_receive_accepts_native_tokens_from_low_level_call_with_value() public {
        uint256 amount = 1 ether;
        vm.deal(msg.sender, amount);

        uint256 balanceBefore = address(this).balance;

        vm.prank(msg.sender);
        vm.expectEmit(address(this));
        emit INativeTokenReceiver.NativeTokenReceived({sender: msg.sender, amount: amount});
        (bool success, bytes memory result) = payable(address(this)).call{value: amount}("");

        uint256 balanceAfter = address(this).balance;

        assertTrue(success);
        assertEq(result, "");
        assertEq(balanceAfter - balanceBefore, amount);
    }

    function test_receive_accepts_native_tokens_from_transfer_call() public {
        uint256 amount = 1 ether;
        vm.deal(msg.sender, amount);

        uint256 balanceBefore = address(this).balance;

        vm.prank(msg.sender);
        vm.expectEmit(address(this));
        emit INativeTokenReceiver.NativeTokenReceived({sender: msg.sender, amount: amount});
        payable(address(this)).transfer(amount);

        uint256 balanceAfter = address(this).balance;

        assertEq(balanceAfter - balanceBefore, amount);
    }

    function test_receive_accepts_native_tokens_from_send_call() public {
        uint256 amount = 1 ether;
        vm.deal(msg.sender, amount);

        uint256 balanceBefore = address(this).balance;

        vm.prank(msg.sender);
        vm.expectEmit(address(this));
        emit INativeTokenReceiver.NativeTokenReceived({sender: msg.sender, amount: amount});

        // solhint-disable-next-line check-send-result
        bool success = payable(address(this)).send(amount);

        uint256 balanceAfter = address(this).balance;

        assertTrue(success);
        assertEq(balanceAfter - balanceBefore, amount);
    }
}
