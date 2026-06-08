// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Address} from "@openzeppelin-contracts-5.6.1/utils/Address.sol";

import {ForwarderBase} from "../../src/ForwarderBase.sol";

contract ForwarderExample is ForwarderBase {
    using Address for address;

    event CallForwarded(bytes input, bytes output);

    constructor(address protocolAdapter, bytes32 logicRef) ForwarderBase(protocolAdapter, logicRef) {}

    function _forwardCall(bytes calldata input) internal override returns (bytes memory output) {
        (address target, bytes memory payload) = abi.decode(input, (address, bytes));
        output = target.functionCall(payload);

        emit CallForwarded({input: input, output: output});
    }
}
