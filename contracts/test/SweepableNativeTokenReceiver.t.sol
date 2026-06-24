// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ISweepable} from "../src/interfaces/ISweepable.sol";
import {SweepableNativeTokenReceiver} from "../src/SweepableNativeTokenReceiver.sol";
import {ERC20Example} from "./examples/ERC20Example.sol";
import {NativeTokenReceiverTest} from "./NativeTokenReceiver.t.sol";

contract SweepableNativeTokenReceiverTest is NativeTokenReceiverTest {
    ERC20Example internal _erc20;

    function setUp() public override {
        _receiver = address(new SweepableNativeTokenReceiver());
        _erc20 = new ERC20Example();
    }

    function test_sweep_sweeps_full_erc20_balance_to_recipient() public {
        _erc20.mint({to: _receiver, value: _AMOUNT});

        assertEq(_erc20.balanceOf(_receiver), _AMOUNT);
        assertEq(_erc20.balanceOf(_ALICE), 0);

        vm.expectEmit(_receiver);
        emit ISweepable.Swept({token: address(_erc20), to: _ALICE, amount: _AMOUNT});
        uint256 amount = ISweepable(_receiver).sweep({token: address(_erc20), to: _ALICE});

        assertEq(amount, _AMOUNT);
        assertEq(_erc20.balanceOf(_ALICE), _AMOUNT);
        assertEq(_erc20.balanceOf(_receiver), 0);
    }

    function test_sweep_sweeps_full_native_balance_to_recipient() public {
        vm.deal(_receiver, _AMOUNT);

        assertEq(_receiver.balance, _AMOUNT);
        assertEq(_ALICE.balance, 0);

        vm.expectEmit(_receiver);
        emit ISweepable.Swept({token: address(0), to: _ALICE, amount: _AMOUNT});
        uint256 amount = ISweepable(_receiver).sweep({token: address(0), to: _ALICE});

        assertEq(amount, _AMOUNT);
        assertEq(_ALICE.balance, _AMOUNT);
        assertEq(_receiver.balance, 0);
    }

    function test_sweep_is_a_noop_when_erc20_balance_is_zero() public {
        vm.expectEmit(_receiver);
        emit ISweepable.Swept({token: address(_erc20), to: _ALICE, amount: 0});
        uint256 amount = ISweepable(_receiver).sweep({token: address(_erc20), to: _ALICE});

        assertEq(amount, 0);
        assertEq(_erc20.balanceOf(_ALICE), 0);
    }

    function test_sweep_is_a_noop_when_native_balance_is_zero() public {
        vm.expectEmit(_receiver);
        emit ISweepable.Swept({token: address(0), to: _ALICE, amount: 0});
        uint256 amount = ISweepable(_receiver).sweep({token: address(0), to: _ALICE});

        assertEq(amount, 0);
        assertEq(_ALICE.balance, 0);
    }
}
