// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {INativeTokenReceiver} from "./interfaces/INativeTokenReceiver.sol";

/// @title NativeTokenReceiver
/// @author Anoma Foundation, 2026
/// @notice A base contract receiving native tokens.
/// @custom:security-contact security@anoma.foundation
contract NativeTokenReceiver is INativeTokenReceiver {
    // NOTE: The inheriting contract needs to implement a method allowing to withdraw the native tokens.
    // slither-disable-start locked-ether

    /// @notice Emits the `NativeTokenReceived` event to track native token deposits.
    /// @dev This call is bound by the gas limitations for `send`/`transfer` calls introduced by
    /// [ERC-2929](https://eips.ethereum.org/EIPS/eip-2929). Gas cost increases in future hard forks might limit this
    /// contract to receive native tokens via low-level calls.
    receive() external payable override {
        emit NativeTokenReceived({sender: msg.sender, amount: msg.value});
    }

    // slither-disable-end locked-ether
}

