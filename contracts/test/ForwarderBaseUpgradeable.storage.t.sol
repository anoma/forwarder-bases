// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SlotDerivation} from "@openzeppelin-contracts-5.6.1/utils/SlotDerivation.sol";
import {Test} from "forge-std-1.16.1/src/Test.sol";

import {ForwarderBaseUpgradeable} from "../src/ForwarderBaseUpgradeable.sol";

contract ForwarderBaseUpgradeableStorageTest is Test, ForwarderBaseUpgradeable {
    function test_storage_slot() public pure {
        assertEq(_FORWARDER_BASE_STORAGE_LOCATION, SlotDerivation.erc7201Slot("anoma.storage.ForwarderBase"));
    }

    function _forwardCall(bytes calldata input) internal pure override returns (bytes memory output) {
        (input);
        output = "";
    }
}
