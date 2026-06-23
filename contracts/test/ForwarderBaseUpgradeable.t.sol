// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC1967Proxy} from "@openzeppelin-contracts-5.6.1/proxy/ERC1967/ERC1967Proxy.sol";
import {ReentrancyGuardTransient} from "@openzeppelin-contracts-5.6.1/utils/ReentrancyGuardTransient.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades-0.4.1/src/Upgrades.sol";

import {ILogicRefSpecific} from "../src/interfaces/ILogicRefSpecific.sol";
import {IProtocolAdapterSpecific} from "../src/interfaces/IProtocolAdapterSpecific.sol";
import {
    ForwarderTargetExample,
    INPUT_VALUE,
    OUTPUT_VALUE,
    EXPECTED_OUTPUT,
    _encodedDefaultInput
} from "./examples/ForwarderTargetExample.sol";
import {ForwarderUpgradeableExample} from "./examples/ForwarderUpgradeableExample.sol";
import {ReentrantTargetExample} from "./examples/ReentrantTargetExample.sol";
import {TestWithRoles} from "./helpers/TestWithRoles.sol";

contract ForwarderBaseUpgradeableUpgradeableTest is TestWithRoles {
    bytes32 internal constant _LOGIC_REF = bytes32(type(uint256).max);

    address internal _pa;

    ForwarderUpgradeableExample internal _fwd;
    ForwarderTargetExample internal _tgt;

    function setUp() public virtual {
        _pa = makeAddr("pa");

        _tgt = new ForwarderTargetExample();
        _fwd = ForwarderUpgradeableExample(
            Upgrades.deployUUPSProxy(
                "ForwarderUpgradeableExample.sol:ForwarderUpgradeableExample",
                abi.encodeCall(ForwarderUpgradeableExample.initialize, (_pa, _LOGIC_REF, _FORWARDER_OWNER))
            )
        );
    }

    function test_forwardCall_reverts_if_the_pa_is_not_the_caller() public {
        vm.prank(_UNAUTHORIZED_CALLER);
        vm.expectRevert(
            abi.encodeWithSelector(
                IProtocolAdapterSpecific.ProtocolAdapterMismatch.selector, _pa, _UNAUTHORIZED_CALLER
            ),
            address(_fwd)
        );
        _fwd.forwardCall({logicRef: _LOGIC_REF, input: _encodedDefaultInput(address(_tgt))});
    }

    function test_forwardCall_reverts_if_the_logic_ref_mismatches() public {
        bytes32 wrongLogicRef = bytes32(uint256(123));

        assertNotEq(wrongLogicRef, _LOGIC_REF);

        vm.prank(_pa);
        vm.expectRevert(
            abi.encodeWithSelector(ILogicRefSpecific.LogicRefMismatch.selector, _LOGIC_REF, wrongLogicRef),
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
        emit ForwarderUpgradeableExample.CallForwarded(input, EXPECTED_OUTPUT);
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

    function test_getImplementation_returns_the_implementation_address() public {
        ForwarderUpgradeableExample implementation = new ForwarderUpgradeableExample();

        // Deploy a proxy delegating to the known implementation.
        ForwarderUpgradeableExample fwd = ForwarderUpgradeableExample(
            address(
                new ERC1967Proxy(
                    address(implementation),
                    abi.encodeCall(ForwarderUpgradeableExample.initialize, (_pa, _LOGIC_REF, _FORWARDER_OWNER))
                )
            )
        );

        assertEq(fwd.getImplementation(), address(implementation));
    }
}
