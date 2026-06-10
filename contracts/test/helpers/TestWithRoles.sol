// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std-1.16.1/src/Test.sol";

/// @title TestWithRoles
/// @notice Base test contract exposing deterministic, labeled role addresses defined once for the whole suite.
abstract contract TestWithRoles is Test {
    address internal immutable _UNAUTHORIZED_CALLER = makeAddr("unauthorized caller");
    address internal immutable _EMERGENCY_CALLER = makeAddr("emergency caller");
    address internal immutable _EMERGENCY_COMMITTEE = makeAddr("emergency committee");
    address internal immutable _PA_OWNER = makeAddr("pa owner");
    address internal immutable _FORWARDER_OWNER = makeAddr("forwarder owner");
}
