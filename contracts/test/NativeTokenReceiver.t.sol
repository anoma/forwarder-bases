// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std-1.16.1/src/Test.sol";

import {INativeTokenReceiver} from "../src/interfaces/INativeTokenReceiver.sol";
import {NativeTokenReceiver} from "../src/NativeTokenReceiver.sol";

contract NativeTokenReceiverTest is Test {
    uint256 internal constant _AMOUNT = 1 ether;
    address internal immutable _ALICE = makeAddr("alice");

    address internal _receiver;

    function setUp() public virtual {
        _receiver = address(new NativeTokenReceiver());
    }

    function test_receive_accepts_native_tokens_from_low_level_call_with_value() public {
        vm.deal(_ALICE, _AMOUNT);

        uint256 balanceBefore = _receiver.balance;

        vm.prank(_ALICE);
        vm.expectEmit(_receiver);
        emit INativeTokenReceiver.NativeTokenReceived({sender: _ALICE, amount: _AMOUNT});
        (bool success, bytes memory result) = payable(_receiver).call{value: _AMOUNT}("");

        uint256 balanceAfter = _receiver.balance;

        assertTrue(success);
        assertEq(result, "");
        assertEq(balanceAfter - balanceBefore, _AMOUNT);
    }

    function test_receive_accepts_native_tokens_from_transfer_call() public {
        vm.deal(_ALICE, _AMOUNT);

        uint256 balanceBefore = _receiver.balance;

        vm.prank(_ALICE);
        vm.expectEmit(_receiver);
        emit INativeTokenReceiver.NativeTokenReceived({sender: _ALICE, amount: _AMOUNT});
        payable(_receiver).transfer(_AMOUNT);

        uint256 balanceAfter = _receiver.balance;

        assertEq(balanceAfter - balanceBefore, _AMOUNT);
    }

    function test_receive_accepts_native_tokens_from_send_call() public {
        vm.deal(_ALICE, _AMOUNT);

        uint256 balanceBefore = _receiver.balance;

        vm.prank(_ALICE);
        vm.expectEmit(_receiver);
        emit INativeTokenReceiver.NativeTokenReceived({sender: _ALICE, amount: _AMOUNT});

        // solhint-disable-next-line check-send-result
        bool success = payable(_receiver).send(_AMOUNT);

        uint256 balanceAfter = _receiver.balance;

        assertTrue(success);
        assertEq(balanceAfter - balanceBefore, _AMOUNT);
    }

    function test_receive_reverts_on_low_level_call_with_non_empty_calldata() public {
        vm.deal(_ALICE, _AMOUNT);

        uint256 receiverBalanceBefore = _receiver.balance;
        uint256 senderBalanceBefore = _ALICE.balance;

        vm.prank(_ALICE);
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory result) = payable(_receiver).call{value: _AMOUNT}(hex"deadbeef");

        assertFalse(success, "non-empty calldata call unexpectedly succeeded");
        assertEq(result, "", "unexpected revert return data");
        assertEq(_receiver.balance, receiverBalanceBefore, "receiver balance changed despite failed call");
        assertEq(_ALICE.balance, senderBalanceBefore, "sender balance changed despite failed call");
    }
}
