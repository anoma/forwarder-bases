// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title ISweepable
/// @author Anoma Foundation, 2026
/// @notice Interface for contracts whose native or ERC-20 token balances can be swept to a recipient.
/// @custom:security-contact security@anoma.foundation
interface ISweepable {
    /// @notice Emitted when tokens are swept from the contract.
    /// @param token The swept ERC-20 token, or the zero address for native tokens.
    /// @param to The recipient of the swept tokens.
    /// @param amount The swept amount.
    event Swept(address indexed token, address indexed to, uint256 amount);

    /// @notice Sweeps the full balance of native or ERC-20 tokens held by this contract to a recipient.
    /// @param token The ERC-20 token to sweep, or the zero address to sweep native tokens.
    /// @param to The recipient of the swept tokens.
    /// @return amount The swept amount.
    function sweep(address token, address to) external returns (uint256 amount);
}

