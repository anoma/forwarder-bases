// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title IFallbackHandler
/// @author Anoma Foundation, 2026
/// @notice The interface of a contract handling fallbacks.
interface IFallbackHandler {
    /// @notice Emitted when a fallback was handled by the fallback handler.
    /// @param sender The sender of the fallback function call.
    /// @param selector The selector of the calling function.
    /// @param data The calldata.
    event FallbackHandled(address indexed sender, bytes4 indexed selector, bytes data);

    /// @notice The fallback function being able handle different ERC standards by responding to registered function
    /// selectors with magic numbers.
    /// @param data An alias being equivalent to `msg.data`. This feature of the fallback function was introduced with
    /// the solidity compiler version 0.7.6 (see https://github.com/ethereum/solidity/releases/tag/v0.7.6).
    /// @return magicNumber The bytes-encoded magic number registered for the selector of the function selector
    /// that is triggering the fallback.
    fallback(bytes calldata data) external returns (bytes memory magicNumber);

    /// @notice Registers a magic number for a callback function selector.
    /// @param selector The selector of the callback function.
    /// @param magicNumber The magic number to be registered for the callback function selector.
    function registerSelector(bytes4 selector, bytes4 magicNumber) external;

    /// @notice Returns the magic number for a registered function selector or `bytes4(0)` if the selector has not been
    /// registered.
    /// @param selector The selector of the function.
    /// @return magicNumber The registered magic number or `bytes4(0)`.
    function lookupMagicNumber(bytes4 selector) external view returns (bytes4 magicNumber);
}
