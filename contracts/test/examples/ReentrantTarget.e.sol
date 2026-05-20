// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IEmergencyMigratable} from "../../src/interfaces/IEmergencyMigratable.sol";
import {IForwarder} from "../../src/interfaces/IForwarder.sol";

/// @notice A malicious forwarder target that re-enters the calling forwarder.
/// @dev Used together with `vm.etch` to overwrite the well-behaved `ForwarderTargetExample` for reentrancy tests.
contract ReentrantTargetExample {
    function reenterForwardCall(bytes32 logicRef) external returns (bytes memory ret) {
        ret = IForwarder(msg.sender).forwardCall({logicRef: logicRef, input: ""});
    }

    function reenterForwardEmergencyCall() external returns (bytes memory ret) {
        ret = IEmergencyMigratable(msg.sender).forwardEmergencyCall({input: ""});
    }
}
