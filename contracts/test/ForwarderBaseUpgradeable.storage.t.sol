// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.30;

import {Test} from "forge-std-1.16.1/src/Test.sol";

import {ForwarderBaseUpgradeable} from "../src/ForwarderBaseUpgradeable.sol";

contract ForwarderBaseUpgradeableStorageTest is Test, ForwarderBaseUpgradeable {
    function test_storageLocation() external pure {
        bytes32 expected =
            keccak256(abi.encode(uint256(keccak256("anoma.storage.ForwarderBase")) - 1)) & ~bytes32(uint256(0xff));

        assertEq(_FORWARDER_BASE_STORAGE_LOCATION, expected);
    }

    function _forwardCall(bytes calldata input)
        internal
        override
        returns (bytes memory output)
    // solhint-disable-next-line no-empty-blocks
    {}
}
