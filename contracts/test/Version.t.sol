// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std-1.15.0/src/Test.sol";

import {Version} from "../src/Version.sol";

contract VersionTest is Test {
    function test_getVersion_returns_the_version_number() public {
        Version versionedContract = new Version({version: "0.0.0-rc.0"});

        assertEq(versionedContract.getVersion(), "0.0.0-rc.0");
    }
}
