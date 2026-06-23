// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title IEmergencyMigratable
/// @author Anoma Foundation, 2026
/// @notice The interface of emergency migratable forwarder contracts.
interface IEmergencyMigratable {
    /// @notice Emitted when the emergency caller is set.
    /// @param emergencyCaller The address of the emergencyCaller.
    event EmergencyCallerSet(address indexed emergencyCaller);

    /// @notice Forwards an external call to read or write EVM state. This function can only be called by the address
    /// set by emergency committee if the RISC Zero emergency stop is active.
    /// @param input The `bytes` encoded calldata (including the `bytes4` function selector).
    /// @return output The `bytes` encoded output of the call.
    function forwardEmergencyCall(bytes memory input) external returns (bytes memory output);

    /// @notice Sets the emergency caller. This function can only be called once by the specified emegrency committee
    /// in the case the appropriate protocol adapter of RiscZero verifier has been stopped.
    /// @param emergencyCaller The emergency caller to set.
    function setEmergencyCaller(address emergencyCaller) external;

    /// @notice Returns the emergency caller.
    /// @return caller The emergency caller.
    function getEmergencyCaller() external view returns (address caller);
}
