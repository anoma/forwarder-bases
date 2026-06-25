// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin-contracts-5.6.1/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin-contracts-5.6.1/token/ERC20/utils/SafeERC20.sol";
import {Address} from "@openzeppelin-contracts-5.6.1/utils/Address.sol";

import {ISweepable} from "./interfaces/ISweepable.sol";
import {NativeTokenReceiver} from "./NativeTokenReceiver.sol";

/// @title SweepableNativeTokenReceiver
/// @author Anoma Foundation, 2026
/// @notice A base contract that receives native tokens and lets anyone sweep its native and ERC-20 token balances to a
/// recipient.
/// @custom:security-contact security@anoma.foundation
contract SweepableNativeTokenReceiver is ISweepable, NativeTokenReceiver {
    using Address for address payable;
    using SafeERC20 for IERC20;

    /// @inheritdoc ISweepable
    /// @dev This function is permissionless and can be called by everyone.
    function sweep(address token, address to) external override returns (uint256 amount) {
        if (to == address(0)) revert ZeroRecipientNotAllowed();

        if (token == address(0)) {
            amount = address(this).balance;
            payable(to).sendValue(amount);
        } else {
            amount = IERC20(token).balanceOf(address(this));
            IERC20(token).safeTransfer({to: to, value: amount});
        }

        emit Swept({token: token, to: to, amount: amount});
    }
}

