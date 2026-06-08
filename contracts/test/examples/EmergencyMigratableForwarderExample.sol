// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Address} from "@openzeppelin-contracts-5.6.1/utils/Address.sol";

import {EmergencyMigratableForwarderBase} from "../../src/EmergencyMigratableForwarderBase.sol";

contract EmergencyMigratableForwarderExample is EmergencyMigratableForwarderBase {
    using Address for address;

    event CallForwarded(bytes input, bytes output);
    event EmergencyCallForwarded(bytes input, bytes output);

    constructor(address protocolAdapter, address emergencyCommittee, bytes32 logicRef)
        EmergencyMigratableForwarderBase(protocolAdapter, logicRef, emergencyCommittee)
    {}

    function _forwardCall(bytes calldata input) internal override returns (bytes memory output) {
        (address target, bytes memory payload) = abi.decode(input, (address, bytes));
        output = target.functionCall(payload);

        emit CallForwarded({input: input, output: output});
    }

    function _forwardEmergencyCall(bytes calldata input) internal override returns (bytes memory output) {
        (address target, bytes memory payload) = abi.decode(input, (address, bytes));
        output = target.functionCall(payload);

        emit EmergencyCallForwarded({input: input, output: output});
    }
}
