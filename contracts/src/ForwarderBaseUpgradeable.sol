// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC1967Utils} from "@openzeppelin-contracts-5.6.1/proxy/ERC1967/ERC1967Utils.sol";
import {Initializable} from "@openzeppelin-contracts-5.6.1/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin-contracts-5.6.1/proxy/utils/UUPSUpgradeable.sol";
import {ReentrancyGuardTransient} from "@openzeppelin-contracts-5.6.1/utils/ReentrancyGuardTransient.sol";
import {OwnableUpgradeable} from "@openzeppelin-contracts-upgradeable-5.6.1/access/OwnableUpgradeable.sol";

import {IForwarder} from "./interfaces/IForwarder.sol";
import {IImplementation} from "./interfaces/IImplementation.sol";
import {ILogicRefSpecific} from "./interfaces/ILogicRefSpecific.sol";
import {IProtocolAdapterSpecific} from "./interfaces/IProtocolAdapterSpecific.sol";

/// @title ForwarderBaseUpgradeable
/// @author Anoma Foundation, 2026
/// @notice A base contract for protocol-adapter- and logic-reference-specific forwarders.
/// @custom:security-contact security@anoma.foundation
abstract contract ForwarderBaseUpgradeable is
    IForwarder,
    IProtocolAdapterSpecific,
    ILogicRefSpecific,
    IImplementation,
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardTransient
{
    /// @notice The ERC-7201 storage of the contract.
    /// @custom:storage-location erc7201:anoma.storage.ForwarderBase
    struct ForwarderBaseStorage {
        // The protocol adapter contract that can forward calls.
        address _protocolAdapter;
        // The reference to the logic function of the resource triggering the forward calls.
        bytes32 _logicRef;
    }

    /// @notice The ERC-7201 storage slot associated with the `ForwarderBaseStorage` struct.
    bytes32 internal constant _FORWARDER_BASE_STORAGE_SLOT =
        0x2bd7b6d3e7cc22d7ab1bb9e579816e4511f108e9e5b105013ce0651501830c00;

    /// @notice Disables the initializers on the implementation contract to prevent it from being left uninitialized.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @inheritdoc IForwarder
    function forwardCall(bytes32 logicRef, bytes calldata input) external nonReentrant returns (bytes memory output) {
        ForwarderBaseStorage storage $ = _getForwarderBaseStorage();

        require(
            msg.sender == $._protocolAdapter,
            IProtocolAdapterSpecific.ProtocolAdapterMismatch({expected: $._protocolAdapter, actual: msg.sender})
        );
        require($._logicRef == logicRef, ILogicRefSpecific.LogicRefMismatch({expected: $._logicRef, actual: logicRef}));

        output = _forwardCall(input);
    }

    /// @inheritdoc IProtocolAdapterSpecific
    function getProtocolAdapter() external view override returns (address protocolAdapter) {
        ForwarderBaseStorage storage $ = _getForwarderBaseStorage();

        protocolAdapter = $._protocolAdapter;
    }

    /// @inheritdoc ILogicRefSpecific
    function getLogicRef() external view override returns (bytes32 logicRef) {
        ForwarderBaseStorage storage $ = _getForwarderBaseStorage();

        logicRef = $._logicRef;
    }

    /// @inheritdoc IImplementation
    function getImplementation() external view override returns (address implementation) {
        implementation = ERC1967Utils.getImplementation();
    }

    // slither-disable-start dead-code

    /// @notice Initializes the upgradeable forwarder base by calling the unchained parent initializers.
    /// @param protocolAdapter The protocol adapter contract that can forward calls.
    /// @param logicRef The reference to the logic function of the resource kind triggering the forward call.
    /// @param initialOwner The initial owner of the forwarder contract that can upgrade the contract.
    // solhint-disable-next-line func-name-mixedcase
    function __ForwarderBaseUpgradeable_init(address protocolAdapter, bytes32 logicRef, address initialOwner)
        internal
        onlyInitializing
    {
        __Ownable_init_unchained({initialOwner: initialOwner});
        __ForwarderBaseUpgradeable_init_unchained({protocolAdapter: protocolAdapter, logicRef: logicRef});
    }

    /// @notice Initializes the upgradeable forwarder base contract.
    /// @param protocolAdapter The protocol adapter contract that can forward calls.
    /// @param logicRef The reference to the logic function of the resource kind triggering the forward call.
    // solhint-disable-next-line func-name-mixedcase
    function __ForwarderBaseUpgradeable_init_unchained(address protocolAdapter, bytes32 logicRef)
        internal
        onlyInitializing
    {
        require(protocolAdapter != address(0), ZeroProtocolAdapterNotAllowed());
        require(logicRef != bytes32(0), ZeroLogicRefNotAllowed());

        ForwarderBaseStorage storage $ = _getForwarderBaseStorage();

        $._protocolAdapter = protocolAdapter;
        $._logicRef = logicRef;
    }

    // slither-disable-end dead-code

    // slither-disable-start unimplemented-functions

    /// @notice Forwards calls.
    /// @param input The `bytes` encoded input of the call.
    /// @return output The `bytes` encoded output of the call.
    function _forwardCall(bytes calldata input) internal virtual returns (bytes memory output);

    // slither-disable-end unimplemented-functions

    /// @notice Authorizes an upgrade.
    /// @param newImpl The new implementation to authorize the upgrade to.
    function _authorizeUpgrade(address newImpl) internal view override onlyOwner {
        (newImpl);
    }

    /// @notice Returns the storage from the forwarder base storage slot.
    /// @return store The data associated with the forwarder base storage.
    function _getForwarderBaseStorage() internal pure returns (ForwarderBaseStorage storage store) {
        /* solhint-disable no-inline-assembly */
        // slither-disable-next-line assembly
        assembly {
            store.slot := _FORWARDER_BASE_STORAGE_SLOT
        }

        /* solhint-enable no-inline-assembly */
    }
}
