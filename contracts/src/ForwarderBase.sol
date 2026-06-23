// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ReentrancyGuardTransient} from "@openzeppelin-contracts-5.6.1/utils/ReentrancyGuardTransient.sol";

import {IForwarder} from "./interfaces/IForwarder.sol";
import {ILogicRefSpecific} from "./interfaces/ILogicRefSpecific.sol";
import {IProtocolAdapterSpecific} from "./interfaces/IProtocolAdapterSpecific.sol";

/// @title ForwarderBase
/// @author Anoma Foundation, 2026
/// @notice A base contract for protocol-adapter- and logic-reference-specific forwarders.
/// @custom:security-contact security@anoma.foundation
abstract contract ForwarderBase is IForwarder, IProtocolAdapterSpecific, ILogicRefSpecific, ReentrancyGuardTransient {
    /// @notice The protocol adapter contract that can forward calls.
    address internal immutable _PROTOCOL_ADAPTER;

    /// @notice The reference to the logic function of the resource kind triggering the forward calls.
    bytes32 internal immutable _LOGIC_REF;

    /// @notice Ensures that the protocol adapter is the function caller.
    modifier onlyProtocolAdapter() {
        require(
            msg.sender == _PROTOCOL_ADAPTER, ProtocolAdapterMismatch({expected: _PROTOCOL_ADAPTER, actual: msg.sender})
        );
        _;
    }

    /// @notice Ensures that the function call is triggered by a resource with the logic reference the forwarder is associated
    /// with.
    /// @param logicRef The logic reference of the resource triggering the forward call.
    modifier onlyLogicRef(bytes32 logicRef) {
        require(_LOGIC_REF == logicRef, LogicRefMismatch({expected: _LOGIC_REF, actual: logicRef}));
        _;
    }

    /// @notice Initializes the forwarder base contract.
    /// @param protocolAdapter The protocol adapter contract that can forward calls.
    /// @param logicRef The reference to the logic function of the resource kind triggering the forward call.
    constructor(address protocolAdapter, bytes32 logicRef) {
        require(protocolAdapter != address(0), ZeroProtocolAdapterNotAllowed());
        require(logicRef != bytes32(0), ZeroLogicRefNotAllowed());

        _PROTOCOL_ADAPTER = protocolAdapter;

        _LOGIC_REF = logicRef;
    }

    /// @inheritdoc IForwarder
    function forwardCall(bytes32 logicRef, bytes calldata input)
        external
        nonReentrant
        onlyProtocolAdapter
        onlyLogicRef(logicRef)
        returns (bytes memory output)
    {
        output = _forwardCall(input);
    }

    /// @inheritdoc IProtocolAdapterSpecific
    function getProtocolAdapter() external view override returns (address protocolAdapter) {
        protocolAdapter = _PROTOCOL_ADAPTER;
    }

    /// @inheritdoc ILogicRefSpecific
    function getLogicRef() external view override returns (bytes32 logicRef) {
        logicRef = _LOGIC_REF;
    }

    // slither-disable-start unimplemented-functions

    /// @notice Forwards calls.
    /// @param input The `bytes` encoded input of the call.
    /// @return output The `bytes` encoded output of the call.
    function _forwardCall(bytes calldata input) internal virtual returns (bytes memory output);

    // slither-disable-end unimplemented-functions
}
