// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {SlotDerivation} from "@openzeppelin-contracts-5.6.1/utils/SlotDerivation.sol";
import {TransientSlot} from "@openzeppelin-contracts-5.6.1/utils/TransientSlot.sol";

import {IFallbackHandler} from "./interfaces/IFallbackHandler.sol";

/// @title TransientFallbackHandler
/// @author Anoma Foundation, 2026
/// @notice A base contract for handling fallbacks by transiently registering a magic number together with the calling
/// function's selector.
/// @dev This contract provides the `_handleFallback` function that is used inside the `fallback()` function.
/// This allows to adaptively register ERC standards that conduct callbacks, e.g.,
/// * ERC-721: Non-Fungible Token Standard (https://eips.ethereum.org/EIPS/eip-721)
/// * ERC-1155: Multi Token Standard (https://eips.ethereum.org/EIPS/eip-1155)
/// * ERC-165: Standard Interface Detection (https://eips.ethereum.org/EIPS/eip-165)
/// that require a magic number to be returned via an associated callback function.
contract TransientFallbackHandler is IFallbackHandler {
    using SlotDerivation for *;
    using TransientSlot for bytes32;
    using TransientSlot for TransientSlot.Bytes32Slot;

    /// @notice The magic number referring to unregistered fallbacks.
    bytes4 internal constant _UNREGISTERED = bytes4(0);

    /// @notice The ERC-7201 storage slot of the transient mapping between callback selectors and magic numbers.
    /// @custom:storage-location erc7201:anoma.transient.selectorsToMagicNumbers
    bytes32 private immutable _SELECTORS_TO_MAGIC_NUMBERS_TRANSIENT_STORAGE_SLOT =
        "anoma.transient.selectorsToMagicNumbers".erc7201Slot();

    /// @notice Thrown if the selector of a calling function is not registered.
    /// @param selector The selector of the calling function.
    /// @param magicNumber The magic number to be registered for the callback function selector.
    error UnregisteredSelector(bytes4 selector, bytes4 magicNumber);

    /// @inheritdoc IFallbackHandler
    fallback(bytes calldata data) // solhint-disable-line payable-fallback
        external
        override
        returns (bytes memory magicNumber)
    {
        magicNumber = abi.encode(_handleFallback(msg.sig, data));
    }

    /// @inheritdoc IFallbackHandler
    function registerSelector(bytes4 selector, bytes4 magicNumber) external override {
        _SELECTORS_TO_MAGIC_NUMBERS_TRANSIENT_STORAGE_SLOT.deriveMapping(bytes32(selector)).asBytes32()
            .tstore(bytes32(magicNumber));
    }

    /// @inheritdoc IFallbackHandler
    function lookupMagicNumber(bytes4 selector) external view override returns (bytes4 magicNumber) {
        magicNumber = bytes4(
            _SELECTORS_TO_MAGIC_NUMBERS_TRANSIENT_STORAGE_SLOT.deriveMapping(bytes32(selector)).asBytes32().tload()
        );
    }

    /// @notice Handles callbacks to adaptively support ERC standards.
    /// @dev This function is supposed to be called via `_handleFallback(msg.sig, msg.data)` in the `fallback()`
    /// function of the inheriting contract.
    /// @param selector The function selector of the callback function.
    /// @param data The calldata.
    /// @return magicNumber The magic number registered for the function selector triggering the fallback.
    function _handleFallback(bytes4 selector, bytes calldata data) internal returns (bytes4 magicNumber) {
        magicNumber = bytes4(
            _SELECTORS_TO_MAGIC_NUMBERS_TRANSIENT_STORAGE_SLOT.deriveMapping(bytes32(selector)).asBytes32().tload()
        );

        require(magicNumber != _UNREGISTERED, UnregisteredSelector({selector: selector, magicNumber: magicNumber}));

        emit FallbackHandled({sender: msg.sender, selector: selector, data: data});
    }
}
