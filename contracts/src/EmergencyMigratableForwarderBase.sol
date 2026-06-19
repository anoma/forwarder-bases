// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Pausable} from "@openzeppelin-contracts-5.6.1/utils/Pausable.sol";
import {ForwarderBase} from "./ForwarderBase.sol";
import {IEmergencyMigratable} from "./interfaces/IEmergencyMigratable.sol";

/// @title EmergencyMigratableForwarderBase
/// @author Anoma Foundation, 2026
/// @notice A forwarder base contract supporting emergency migration to a future protocol adapter version.
/// @custom:security-contact security@anoma.foundation
abstract contract EmergencyMigratableForwarderBase is IEmergencyMigratable, ForwarderBase {
    /// @notice The emergency committee address allowed to set an emergency caller in case either the protocol adapter
    /// or the appropriate RiscZero verifier has stopped.
    address internal immutable _EMERGENCY_COMMITTEE;

    /// @notice The emergency caller that the emergency committee can set once.
    address internal _emergencyCaller;

    error EmergencyCallerAlreadySet(address emergencyCaller);
    error ProtocolAdapterNotStopped();

    /// @notice Initializes the contract.
    /// @param protocolAdapter The protocol adapter contract that can forward calls.
    /// @param logicRef The reference to the logic function of the resource kind triggering the forward call.
    /// @param emergencyCommittee The emergency committee that can set the emergency caller if the protocol adapter or
    /// the appropriate RiscZero verifier has stopped.
    constructor(address protocolAdapter, bytes32 logicRef, address emergencyCommittee)
        ForwarderBase(protocolAdapter, logicRef)
    {
        require(emergencyCommittee != address(0), ZeroNotAllowed());

        _EMERGENCY_COMMITTEE = emergencyCommittee;
    }

    /// @inheritdoc IEmergencyMigratable
    function forwardEmergencyCall(bytes calldata input) external nonReentrant returns (bytes memory output) {
        require(msg.sender == _emergencyCaller, UnauthorizedCaller({expected: _emergencyCaller, actual: msg.sender}));
        require(Pausable(_PROTOCOL_ADAPTER).paused(), ProtocolAdapterNotStopped());

        output = _forwardEmergencyCall(input);
    }

    /// @inheritdoc IEmergencyMigratable
    function setEmergencyCaller(address emergencyCaller) external {
        require(
            msg.sender == _EMERGENCY_COMMITTEE, UnauthorizedCaller({expected: _EMERGENCY_COMMITTEE, actual: msg.sender})
        );
        require(Pausable(_PROTOCOL_ADAPTER).paused(), ProtocolAdapterNotStopped());
        require(emergencyCaller != address(0), ZeroNotAllowed());
        require(_emergencyCaller == address(0), EmergencyCallerAlreadySet(_emergencyCaller));

        _emergencyCaller = emergencyCaller;
    }

    /// @inheritdoc IEmergencyMigratable
    function getEmergencyCaller() external view returns (address caller) {
        caller = _emergencyCaller;
    }

    // slither-disable-start unimplemented-functions

    /// @notice Forwards emergency calls.
    /// @param input The `bytes`  encoded input of the call.
    /// @return output The `bytes` encoded output of the call.
    function _forwardEmergencyCall(bytes calldata input) internal virtual returns (bytes memory output);

    // slither-disable-end unimplemented-functions
}
