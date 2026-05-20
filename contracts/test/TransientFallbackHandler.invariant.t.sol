// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SlotDerivation} from "@openzeppelin-contracts-5.6.1/utils/SlotDerivation.sol";
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
    using SlotDerivation for bytes32;

    bytes4 internal constant _UNREGISTERED = bytes4(0);

    TransientFallbackHandler internal _handler;
    RegistererHandler internal _registerer;

    function setUp() public {
        _handler = new TransientFallbackHandler();
        _registerer = new RegistererHandler(_handler);
        targetContract(address(_registerer));
    }

    /// @notice Each fuzzer call to `RegistererHandler.register` is its own transaction, so transient storage written
    /// there must not be visible from this invariant-check transaction.

    /// @notice The fallback path must also observe the cleared transient slot — calling a selector that was registered
    /// in a previous transaction must revert with `UnregisteredSelector`.
    function invariant_fallback_reverts_for_selectors_registered_in_a_previous_transaction() public {
        bytes4 probe = _registerer.PROBE_SELECTOR();

        // solhint-disable-next-line avoid-low-level-calls
        (bool ok, bytes memory returnData) = address(_handler).call(abi.encodeWithSelector(probe));

        assertFalse(ok, "fallback did not revert for a selector registered in a previous transaction");
        assertEq(
            returnData,
            abi.encodeWithSelector(TransientFallbackHandler.UnregisteredSelector.selector, probe, _UNREGISTERED),
            "fallback reverted with an unexpected reason"
        );
    }

    function invariant_registerSelector_registers_selectors_and_magic_numbers_transiently() public view {
        assertEq(
            _handler.lookupMagicNumber(_registerer.PROBE_SELECTOR()),
            _UNREGISTERED,
            "a magic number was registered across transactions"
        );
    }

    /// @notice The contract must only ever use transient storage — the persistent storage slot derived for any probed
    /// selector must always read as zero, even after registrations in previous transactions.
    function invariant_persistent_storage_at_the_transient_slot_is_never_written() public view {
        bytes32 derivedSlot =
            _handler.ERC7201_SELECTORS_TO_MAGIC_NUMBERS_SLOT().deriveMapping(bytes32(_registerer.PROBE_SELECTOR()));
        assertEq(
            vm.load(address(_handler), derivedSlot),
            bytes32(0),
            "persistent storage was written at the transient slot - was tstore swapped for sstore?"
        );
    }
}
