// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title IProtocolAdapterSpecific
/// @author Anoma Foundation, 2026
/// @notice The interface of contracts being associated with a specific protocol adapter.
interface IProtocolAdapterSpecific {
    /// @notice Thrown if the zero address is provided as the protocol adapter during initialization.
    error ZeroProtocolAdapterNotAllowed();

    /// @notice Thrown if the calling address mismatches the protocol adapter this contract is specifically associated
    /// with.
    /// @param expected The expected protocol adapter address.
    /// @param actual The actual protocol adapter address.
    error ProtocolAdapterMismatch(address expected, address actual);

    /// @notice Returns the protocol adapter contract address this contract is associated with.
    /// @return protocolAdapter The protocol adapter contract address.
    function getProtocolAdapter() external view returns (address protocolAdapter);
}
