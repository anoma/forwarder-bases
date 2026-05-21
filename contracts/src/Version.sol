// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IVersion} from "./interfaces/IVersion.sol";

/// @title Version
/// @author Anoma Foundation, 2026
/// @notice A base contract to inherit from when versioning contracts.
/// @custom:security-contact security@anoma.foundation
contract Version is IVersion {
    /// @notice The version number of the contract.
    bytes32 internal immutable _VERSION;

    /// @notice Initializes the contract semantic version number.
    /// @param version The semantic version number.
    constructor(bytes32 version) {
        _VERSION = version;
    }

    /// @inheritdoc IVersion
    function getVersion() external view override returns (bytes32 version) {
        version = _VERSION;
    }
}
