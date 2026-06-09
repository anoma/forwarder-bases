// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {UUPSUpgradeable} from "@openzeppelin-contracts-5.6.1/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin-contracts-upgradeable-5.6.1/access/OwnableUpgradeable.sol";
import {Test} from "forge-std-1.16.1/src/Test.sol";
import {Options} from "openzeppelin-foundry-upgrades-0.4.1/src/Options.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades-0.4.1/src/Upgrades.sol";

import {ForwarderTargetExample} from "./examples/ForwarderTargetExample.sol";
import {ForwarderUpgradeableExample, ForwarderUpgradeableExampleV2} from "./examples/ForwarderUpgradeableExample.sol";
import {ProtocolAdapterMock} from "./examples/ProtocolAdapter.m.sol";

contract ForwarderBaseUpgradeableUpgradeTest is Test {
    address internal constant _UNAUTHORIZED_CALLER = address(uint160(1));
    address internal constant _PA_OWNER = address(uint160(2));
    address internal constant _FORWARDER_OWNER = address(uint160(3));

    bytes32 internal constant _LOGIC_REF = bytes32(type(uint256).max);

    address internal _pa;
    address internal _fwd;
    ForwarderTargetExample internal _tgt;

    function setUp() public {
        _pa = address(new ProtocolAdapterMock(_PA_OWNER));

        _tgt = new ForwarderTargetExample();
        _fwd = Upgrades.deployUUPSProxy(
            "ForwarderUpgradeableExample.sol:ForwarderUpgradeableExample",
            abi.encodeCall(ForwarderUpgradeableExample.initialize, (_pa, _LOGIC_REF, _FORWARDER_OWNER))
        );
    }

    function test_upgrade_reverts_if_the_caller_is_not_the_owner() public {
        // `Upgrades.upgradeProxy` deploys the new implementation internally, which would be swallowed by
        // `vm.expectRevert`. Validate and deploy the implementation first, then drive the upgrade directly so the
        // revert assertion only covers the `upgradeToAndCall` invocation.
        Options memory opts;
        address newImpl = Upgrades.prepareUpgrade("ForwarderUpgradeableExample.sol:ForwarderUpgradeableExampleV2", opts);

        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, address(this)));
        UUPSUpgradeable(_fwd).upgradeToAndCall(newImpl, abi.encodeCall(ForwarderUpgradeableExampleV2.reinitialize, ()));
    }

    function test_upgrade_upgrades_to_the_same_version() public {
        // `startPrank`/`stopPrank` keeps `_PA_OWNER` as the caller across the implementation deploy and the
        // `upgradeToAndCall` that `Upgrades.upgradeProxy` performs internally; a single `vm.prank` would only apply
        // to the deploy.
        vm.startPrank(_FORWARDER_OWNER);
        Upgrades.upgradeProxy(
            _fwd,
            "ForwarderUpgradeableExample.sol:ForwarderUpgradeableExampleV2",
            abi.encodeCall(ForwarderUpgradeableExampleV2.reinitialize, ())
        );
        vm.stopPrank();
    }
}
