// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title ILogicRefSpecific
/// @author Anoma Foundation, 2026
/// @notice The interface contracts being associated with a specific resource logic function reference.
interface ILogicRefSpecific {
    error ZeroLogicRefNotAllowed();
    error LogicRefMismatch(bytes32 expected, bytes32 actual);

    /// @notice Returns the resource logic function reference this contract is associated with.
    /// @return logicRef The resource logic function reference.
    function getLogicRef() external view returns (bytes32 logicRef);
}
