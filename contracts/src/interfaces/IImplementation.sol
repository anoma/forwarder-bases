// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title IImplementation
/// @author Anoma Foundation, 2026
/// @notice The interface for proxies exposing the implementation contract they delegate to.
/// @custom:security-contact security@anoma.foundation
interface IImplementation {
    /// @notice Returns the implementation contract address the proxy currently delegates to.
    /// @return implementation The [ERC-1967](https://eips.ethereum.org/EIPS/eip-1967) implementation address.
    function getImplementation() external view returns (address implementation);
}
