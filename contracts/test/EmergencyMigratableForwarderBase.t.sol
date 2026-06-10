// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ReentrancyGuardTransient} from "@openzeppelin-contracts-5.6.1/utils/ReentrancyGuardTransient.sol";

import {EmergencyMigratableForwarderBase} from "../src/EmergencyMigratableForwarderBase.sol";
import {ForwarderBase} from "../src/ForwarderBase.sol";
import {EmergencyMigratableForwarderExample} from "./examples/EmergencyMigratableForwarderExample.sol";
import {ForwarderExample} from "./examples/ForwarderExample.sol";
import {
    ForwarderTargetExample,
    INPUT_VALUE,
    OUTPUT_VALUE,
    EXPECTED_OUTPUT,
    _encodedDefaultInput
} from "./examples/ForwarderTargetExample.sol";
import {ProtocolAdapterMock} from "./mocks/ProtocolAdapterMock.sol";
import {ReentrantTargetExample} from "./examples/ReentrantTargetExample.sol";
import {ForwarderBaseTest} from "./ForwarderBase.t.sol";

contract EmergencyMigratableForwarderBaseTest is ForwarderBaseTest {
    EmergencyMigratableForwarderExample internal _emrgFwd;

    function setUp() public override {
        _pa = address(new ProtocolAdapterMock(_PA_OWNER));

        _tgt = new ForwarderTargetExample();

        _emrgFwd = new EmergencyMigratableForwarderExample({
            protocolAdapter: _pa, emergencyCommittee: _EMERGENCY_COMMITTEE, logicRef: _LOGIC_REF
        });

        _fwd = ForwarderExample(address(_emrgFwd));
    }

    function test_constructor_reverts_if_the_emergency_committe_address_is_zero() public {
        address predicted = vm.computeCreateAddress(address(this), vm.getNonce(address(this)));

        vm.expectRevert(ForwarderBase.ZeroNotAllowed.selector, predicted);
        new EmergencyMigratableForwarderExample({
            protocolAdapter: _pa, emergencyCommittee: address(0), logicRef: _LOGIC_REF
        });
    }

    function test_setEmergencyCaller_reverts_if_the_caller_is_not_the_emergency_committee() public {
        vm.prank(_UNAUTHORIZED_CALLER);
        vm.expectRevert(
            abi.encodeWithSelector(
                ForwarderBase.UnauthorizedCaller.selector, _EMERGENCY_COMMITTEE, _UNAUTHORIZED_CALLER
            ),
            address(_fwd)
        );
        _emrgFwd.setEmergencyCaller(_EMERGENCY_CALLER);
    }

    function test_setEmergencyCaller_reverts_if_the_new_emergency_caller_is_the_zero_address() public {
        vm.prank(_EMERGENCY_COMMITTEE);
        vm.expectRevert(ForwarderBase.ZeroNotAllowed.selector, address(_fwd));

        _emrgFwd.setEmergencyCaller(address(0));
    }

    function test_setEmergencyCaller_reverts_if_the_emergency_caller_has_already_been_set() public {
        _stopProtocolAdapter();
        _setEmergencyCaller();

        vm.prank(_EMERGENCY_COMMITTEE);
        vm.expectRevert(
            abi.encodeWithSelector(
                EmergencyMigratableForwarderBase.EmergencyCallerAlreadySet.selector, _EMERGENCY_CALLER
            ),
            address(_fwd)
        );
        _emrgFwd.setEmergencyCaller(_UNAUTHORIZED_CALLER);
    }

    function test_setEmergencyCaller_reverts_if_the_pa_is_not_stopped() public {
        vm.prank(_EMERGENCY_COMMITTEE);
        vm.expectRevert(EmergencyMigratableForwarderBase.ProtocolAdapterNotStopped.selector, address(_fwd));
        _emrgFwd.setEmergencyCaller(_EMERGENCY_CALLER);
    }

    function test_setEmergencyCaller_sets_the_emergency_caller() public {
        _stopProtocolAdapter();
        _setEmergencyCaller();

        assertEq(_emrgFwd.getEmergencyCaller(), _EMERGENCY_CALLER);
    }

    function test_forwardEmergencyCall_reverts_if_the_pa_is_stopped_but_the_emergency_caller_is_not_set() public {
        _stopProtocolAdapter();

        vm.expectRevert(EmergencyMigratableForwarderBase.EmergencyCallerNotSet.selector);
        _emrgFwd.forwardEmergencyCall({input: _encodedDefaultInput(address(_tgt))});
    }

    function test_forwardEmergencyCall_reverts_if_the_pa_is_stopped_but_the_caller_is_not_the_emergency_caller()
        public
    {
        _stopProtocolAdapter();
        _setEmergencyCaller();

        vm.prank(_UNAUTHORIZED_CALLER);
        vm.expectRevert(
            abi.encodeWithSelector(ForwarderBase.UnauthorizedCaller.selector, _EMERGENCY_CALLER, _UNAUTHORIZED_CALLER)
        );
        _emrgFwd.forwardEmergencyCall({input: _encodedDefaultInput(address(_tgt))});
    }

    function test_forwardEmergencyCall_reverts_if_the_pa_is_not_stopped() public {
        _stopProtocolAdapter();
        _setEmergencyCaller();
        _resumeProtocolAdapter();

        vm.prank(_EMERGENCY_CALLER);
        vm.expectRevert(EmergencyMigratableForwarderBase.ProtocolAdapterNotStopped.selector, address(_fwd));
        _emrgFwd.forwardEmergencyCall({input: _encodedDefaultInput(address(_tgt))});
    }

    function test_forwardEmergencyCall_reverts_when_the_target_reenters() public {
        _stopProtocolAdapter();
        _setEmergencyCaller();

        ReentrantTargetExample reentrant = new ReentrantTargetExample();
        bytes memory reentrantInput =
            abi.encode(address(reentrant), abi.encodeCall(ReentrantTargetExample.reenterForwardEmergencyCall, ()));

        vm.prank(_EMERGENCY_CALLER);
        vm.expectRevert(ReentrancyGuardTransient.ReentrancyGuardReentrantCall.selector, address(_emrgFwd));
        _emrgFwd.forwardEmergencyCall({input: reentrantInput});
    }

    function test_forwardEmergencyCall_forwards_calls_if_the_pa_is_stopped_and_the_caller_is_the_emergency_caller()
        public
    {
        _stopProtocolAdapter();
        _setEmergencyCaller();

        vm.prank(_EMERGENCY_CALLER);
        bytes memory output = _emrgFwd.forwardEmergencyCall({input: _encodedDefaultInput(address(_tgt))});
        assertEq(keccak256(output), keccak256(EXPECTED_OUTPUT));
    }

    function test_forwardEmergencyCall_emits_the_EmergencyCallForwarded_event() public {
        _stopProtocolAdapter();
        _setEmergencyCaller();

        bytes memory input = _encodedDefaultInput(address(_tgt));

        vm.prank(_EMERGENCY_CALLER);
        vm.expectEmit(address(_emrgFwd));
        emit EmergencyMigratableForwarderExample.EmergencyCallForwarded(input, EXPECTED_OUTPUT);
        _emrgFwd.forwardEmergencyCall({input: input});
    }

    function test_forwardEmergencyCall_calls_the_function_in_the_target_contract() public {
        _stopProtocolAdapter();
        _setEmergencyCaller();
        vm.prank(_EMERGENCY_CALLER);

        vm.expectEmit(address(_tgt));
        emit ForwarderTargetExample.CallReceived(INPUT_VALUE, OUTPUT_VALUE);
        _emrgFwd.forwardEmergencyCall({input: _encodedDefaultInput(address(_tgt))});
    }

    function test_emergencyCaller_returns_the_emergency_caller_after_it_has_been_set() public {
        _stopProtocolAdapter();
        _setEmergencyCaller();

        assertEq(_emrgFwd.getEmergencyCaller(), _EMERGENCY_CALLER);
    }

    function test_emergencyCaller_returns_zero_if_the_emergency_caller_has_not_been_set() public view {
        assertEq(_emrgFwd.getEmergencyCaller(), address(0));
    }

    function _stopProtocolAdapter() internal {
        vm.prank(_PA_OWNER);
        ProtocolAdapterMock(_pa).emergencyStop();
    }

    function _resumeProtocolAdapter() internal {
        vm.prank(_PA_OWNER);
        ProtocolAdapterMock(_pa).resume();
    }

    function _setEmergencyCaller() private {
        vm.prank(_EMERGENCY_COMMITTEE);
        _emrgFwd.setEmergencyCaller(_EMERGENCY_CALLER);
    }
}
