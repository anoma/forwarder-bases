// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std-1.16.1/src/Test.sol";

import {TransientFallbackHandler} from "../src/TransientFallbackHandler.sol";

contract TransientFallbackHandlerStorageTest is Test {
    function test_magic_numbers_storage_slot() public {
        TransientFallbackHandler handler = new TransientFallbackHandler();
        assertEq(
            handler.ERC7201_SELECTORS_TO_MAGIC_NUMBERS_SLOT(),
            bytes32(erc7201("anoma.transient.selectorsToMagicNumbers"))
        );
    }
}
