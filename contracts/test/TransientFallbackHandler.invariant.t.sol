// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std-1.16.1/src/Test.sol";

import {TransientFallbackHandler} from "../src/TransientFallbackHandler.sol";

contract RegistererHandler {
    bytes4 public constant PROBE_SELECTOR = 0xdead1234;
    bytes4 public constant PROBE_MAGIC_NUMBER = 0xbeef5678;

    TransientFallbackHandler internal _handler;

    constructor(TransientFallbackHandler handler) {
        _handler = handler;
    }

    function register() external {
        _handler.registerSelector({selector: PROBE_SELECTOR, magicNumber: PROBE_MAGIC_NUMBER});
    }
}

contract TransientFallbackHandlerInvariantTest is Test {
    TransientFallbackHandler internal _handler;
    RegistererHandler internal _registerer;

    function setUp() public {
        _handler = new TransientFallbackHandler();
        _registerer = new RegistererHandler(_handler);
        targetContract(address(_registerer));
    }

    /// @notice Each fuzzer call to `RegistererHandler.register` is its own transaction, so transient storage written
    /// there must not be visible from this invariant-check transaction.
    function invariant_registerSelector_registers_selectors_and_magic_numbers_transiently() public view {
        assertEq(
            _handler.lookupMagicNumber(_registerer.PROBE_SELECTOR()),
            bytes4(0),
            "a magic number was registered across transactions"
        );
    }
}
