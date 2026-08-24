// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title IVersion
/// @author Anoma Foundation, 2026
/// @notice The interface for versioned contracts.
/// @custom:security-contact security@anoma.foundation
interface IVersion {
    // solhint-disable func-name-mixedcase

    /// @notice The version of the contract implementation.
    /// @return version The semantic version.
    function VERSION() external view returns (string memory version);

    // solhint-enable func-name-mixedcase
}
