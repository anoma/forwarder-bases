// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ReentrancyGuardTransient} from "@openzeppelin-contracts-5.6.1/utils/ReentrancyGuardTransient.sol";
import {Test} from "forge-std-1.16.1/src/Test.sol";

import {ForwarderBase} from "../src/ForwarderBase.sol";
import {ForwarderExample} from "./examples/Forwarder.e.sol";
import {
    ForwarderTargetExample,
    INPUT_VALUE,
    OUTPUT_VALUE,
    EXPECTED_OUTPUT,
    _encodedDefaultInput
} from "./examples/ForwarderTarget.e.sol";
import {ProtocolAdapterMock} from "./examples/ProtocolAdapter.m.sol";
import {ReentrantTargetExample} from "./examples/ReentrantTarget.e.sol";

contract ForwarderBaseTest is Test {
    address internal constant _EMERGENCY_CALLER = address(uint160(1));
    address internal constant _UNAUTHORIZED_CALLER = address(uint160(2));
    address internal constant _PA_OWNER = address(uint160(3));

    bytes32 internal constant _LOGIC_REF = bytes32(type(uint256).max);

    address internal _pa;

    ForwarderExample internal _fwd;
    ForwarderTargetExample internal _tgt;

    function setUp() public virtual {
        _pa = address(new ProtocolAdapterMock(_PA_OWNER));

        _tgt = new ForwarderTargetExample();
        _fwd = new ForwarderExample({protocolAdapter: _pa, logicRef: _LOGIC_REF});
    }

    function test_constructor_reverts_if_the_protocol_adapter_address_is_zero() public {
        vm.expectRevert(ForwarderBase.ZeroNotAllowed.selector, address(_fwd));
        new ForwarderExample({protocolAdapter: address(0), logicRef: _LOGIC_REF});
    }

    function test_constructor_reverts_if_the_logic_ref_is_zero() public {
        vm.expectRevert(ForwarderBase.ZeroNotAllowed.selector, address(_fwd));
        new ForwarderExample({protocolAdapter: _pa, logicRef: bytes32(0)});
    }

    function test_forwardCall_reverts_if_the_pa_is_not_the_caller() public {
        vm.prank(_UNAUTHORIZED_CALLER);
        vm.expectRevert(
            abi.encodeWithSelector(ForwarderBase.UnauthorizedCaller.selector, _pa, _UNAUTHORIZED_CALLER), address(_fwd)
        );
        _fwd.forwardCall({logicRef: _LOGIC_REF, input: _encodedDefaultInput(address(_tgt))});
    }

    function test_forwardCall_reverts_if_the_logic_ref_mismatches() public {
        bytes32 wrongLogicRef = bytes32(uint256(123));

        assertNotEq(wrongLogicRef, _LOGIC_REF);

        vm.prank(_pa);
        vm.expectRevert(
            abi.encodeWithSelector(ForwarderBase.UnauthorizedLogicRef.selector, _LOGIC_REF, wrongLogicRef),
            address(_fwd)
        );
        _fwd.forwardCall({logicRef: wrongLogicRef, input: _encodedDefaultInput(address(_tgt))});
    }

    function test_forwardCall_reverts_when_the_target_reenters() public {
        ReentrantTargetExample reentrant = new ReentrantTargetExample();
        bytes memory reentrantInput =
            abi.encode(address(reentrant), abi.encodeCall(ReentrantTargetExample.reenterForwardCall, (_LOGIC_REF)));

        vm.prank(_pa);
        vm.expectRevert(ReentrancyGuardTransient.ReentrancyGuardReentrantCall.selector, address(_fwd));
        _fwd.forwardCall({logicRef: _LOGIC_REF, input: reentrantInput});
    }

    function test_forwardCall_forwards_calls_if_the_pa_is_the_caller() public {
        vm.prank(_pa);
        bytes memory output = _fwd.forwardCall({logicRef: _LOGIC_REF, input: _encodedDefaultInput(address(_tgt))});
        assertEq(keccak256(output), keccak256(EXPECTED_OUTPUT));
    }

    function test_forwardCall_emits_the_CallForwarded_event() public {
        bytes memory input = _encodedDefaultInput(address(_tgt));

        vm.prank(_pa);

        vm.expectEmit(address(_fwd));
        emit ForwarderExample.CallForwarded(input, EXPECTED_OUTPUT);
        _fwd.forwardCall({logicRef: _LOGIC_REF, input: input});
    }

    function test_forwardCall_calls_the_function_in_the_target_contract() public {
        vm.prank(_pa);

        vm.expectEmit(address(_tgt));
        emit ForwarderTargetExample.CallReceived(INPUT_VALUE, OUTPUT_VALUE);
        _fwd.forwardCall({logicRef: _LOGIC_REF, input: _encodedDefaultInput(address(_tgt))});
    }

    function test_getProtocolAdapter_returns_the_protocol_adapter_address() public view {
        assertEq(_fwd.getProtocolAdapter(), _pa);
    }

    function test_getLogicRef_returns_the_logic_ref() public view {
        assertEq(_fwd.getLogicRef(), _LOGIC_REF);
    }

    function _stopProtocolAdapter() internal {
        vm.prank(_PA_OWNER);
        ProtocolAdapterMock(_pa).emergencyStop();
    }
}
