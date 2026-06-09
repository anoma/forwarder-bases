// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std-1.16.1/src/Test.sol";

import {ForwarderBaseUpgradeable} from "../src/ForwarderBaseUpgradeable.sol";

contract ForwarderBaseUpgradeableStorageTest is Test, ForwarderBaseUpgradeable {
    function test_storage_slot() public {
        assertEq(_FORWARDER_BASE_STORAGE_LOCATION, bytes32(erc7201("anoma.storage.ForwarderBase")));
    }

    function _forwardCall(bytes calldata input) internal override returns (bytes memory output) {
        (input);
        output = "";
    }
}
