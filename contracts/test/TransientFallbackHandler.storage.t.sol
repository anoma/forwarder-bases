// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std-1.15.0/src/Test.sol";

import {TransientFallbackHandler} from "../src/TransientFallbackHandler.sol";

contract TransientFallbackHandlerStorageTest is Test, TransientFallbackHandler {
    function test_magic_numbers_storage_slot() public pure {
        assertEq(_SELECTORS_TO_MAGIC_NUMBERS_SLOT, bytes32(erc7201("anoma.transient.selectorsToMagicNumbers")));
    }
}
