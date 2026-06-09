// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std-1.16.1/src/Test.sol";

import {ForwarderUpgradeableExample} from "./examples/ForwarderUpgradeableExample.sol";

contract ForwarderBaseUpgradeableStorageTest is Test {
    function test_storage_slot() public {
        ForwarderUpgradeableExample impl = new ForwarderUpgradeableExample();
        assertEq(impl.FORWARDER_BASE_STORAGE_LOCATION(), bytes32(erc7201("anoma.storage.ForwarderBase")));
    }
}
