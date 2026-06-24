// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title IEmergencyMigratable
/// @author Anoma Foundation, 2026
/// @notice The interface of emergency migratable forwarder contracts.
interface IEmergencyMigratable {
    /// @notice Emitted when the emergency caller is set.
    /// @param emergencyCaller The address of the emergencyCaller.
    event EmergencyCallerSet(address indexed emergencyCaller);

    /// @notice Thrown if the zero address is provided as the emergency committee during initialization.
    error ZeroEmergencyCommitteeNotAllowed();

    /// @notice Thrown if the calling address mismatches the emergency committee this contract is specifically
    /// associated with.
    /// @param expected The expected emergency committee address.
    /// @param actual The actual emergency committee address.
    error EmergencyCommitteeMismatch(address expected, address actual);

    /// @notice Thrown if the zero address is provided as the emergency caller.
    error ZeroEmergencyCallerNotAllowed();

    /// @notice Thrown if the calling address mismatches the emergency caller this contract is specifically associated
    /// with.
    /// @param expected The expected emergency caller address.
    /// @param actual The actual emergency caller address.
    error EmergencyCallerMismatch(address expected, address actual);

    /// @notice Thrown if the emergency caller has already been set.
    /// @param emergencyCaller The emergency caller that is already set.
    error EmergencyCallerAlreadySet(address emergencyCaller);

    /// @notice Forwards an external call to read or write EVM state. This function can only be called by the address
    /// set by emergency committee if the RISC Zero emergency stop is active.
    /// @param input The `bytes` encoded calldata (including the `bytes4` function selector).
    /// @return output The `bytes` encoded output of the call.
    function forwardEmergencyCall(bytes memory input) external returns (bytes memory output);

    /// @notice Sets the emergency caller. This function can only be called once by the specified emergency committee
    /// in the case the appropriate protocol adapter of RiscZero verifier has been stopped.
    /// @param emergencyCaller The emergency caller to set.
    function setEmergencyCaller(address emergencyCaller) external;

    /// @notice Returns the emergency caller.
    /// @return caller The emergency caller.
    function getEmergencyCaller() external view returns (address caller);
}
