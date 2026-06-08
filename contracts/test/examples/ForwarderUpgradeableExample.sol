// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Address} from "@openzeppelin-contracts-5.6.1/utils/Address.sol";

import {ForwarderBaseUpgradeable} from "../../src/ForwarderBaseUpgradeable.sol";

contract ForwarderUpgradeableExample is ForwarderBaseUpgradeable {
    using Address for address;

    event CallForwarded(bytes input, bytes output);

    function initialize( /* solhint-disable-line comprehensive-interface*/
        address protocolAdapter,
        bytes32 logicRef,
        address initialOwner
    )
        external
        virtual
        initializer
    {
        __ForwarderBaseUpgradeable_init({
            protocolAdapter: protocolAdapter, logicRef: logicRef, initialOwner: initialOwner
        });
    }

    function _forwardCall(bytes calldata input) internal virtual override returns (bytes memory output) {
        (address target, bytes memory payload) = abi.decode(input, (address, bytes));
        output = target.functionCall(payload);

        emit CallForwarded({input: input, output: output});
    }
}

/// @custom:oz-upgrades-from ForwarderUpgradeableExample
contract ForwarderUpgradeableExampleV2 is ForwarderUpgradeableExample {
    // solhint-disable-next-line omprehensive-interface
    function initialize(address protocolAdapter, bytes32 logicRef, address initialOwner)
        external
        override
        reinitializer(2)
    {
        __ForwarderBaseUpgradeable_init({
            protocolAdapter: protocolAdapter, logicRef: logicRef, initialOwner: initialOwner
        });
    }

    // solhint-disable-next-line no-empty-blocks
    function reinitialize() external reinitializer(2) {}

    function _forwardCall(bytes calldata input) internal override returns (bytes memory output) {
        output = super._forwardCall({input: input});
    }
}
