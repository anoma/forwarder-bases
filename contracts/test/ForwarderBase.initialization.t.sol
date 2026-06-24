// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std-1.16.1/src/Test.sol";

import {ILogicRefSpecific} from "../src/interfaces/ILogicRefSpecific.sol";
import {IProtocolAdapterSpecific} from "../src/interfaces/IProtocolAdapterSpecific.sol";
import {ForwarderExample} from "./examples/ForwarderExample.sol";

contract ForwarderBaseInitializationTest is Test {
    address internal constant _PA = address(uint160(3));
    bytes32 internal constant _LOGIC_REF = bytes32(type(uint256).max);

    function test_constructor_reverts_if_the_protocol_adapter_address_is_zero() public {
        address predicted = vm.computeCreateAddress(address(this), vm.getNonce(address(this)));

        vm.expectRevert(IProtocolAdapterSpecific.ZeroProtocolAdapterNotAllowed.selector, predicted);
        new ForwarderExample({protocolAdapter: address(0), logicRef: _LOGIC_REF});
    }

    function test_constructor_reverts_if_the_logic_ref_is_zero() public {
        address predicted = vm.computeCreateAddress(address(this), vm.getNonce(address(this)));

        vm.expectRevert(ILogicRefSpecific.ZeroLogicRefNotAllowed.selector, predicted);
        new ForwarderExample({protocolAdapter: _PA, logicRef: bytes32(0)});
    }
}
