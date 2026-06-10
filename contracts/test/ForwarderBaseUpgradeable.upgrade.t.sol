// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC1967} from "@openzeppelin-contracts-5.6.1/interfaces/IERC1967.sol";
import {Initializable} from "@openzeppelin-contracts-5.6.1/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin-contracts-upgradeable-5.6.1/access/OwnableUpgradeable.sol";
import {Test} from "forge-std-1.16.1/src/Test.sol";
import {Options} from "openzeppelin-foundry-upgrades-0.4.1/src/Options.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades-0.4.1/src/Upgrades.sol";

import {ForwarderTargetExample} from "./examples/ForwarderTargetExample.sol";
import {ForwarderUpgradeableExample, ForwarderUpgradeableExampleV2} from "./examples/ForwarderUpgradeableExample.sol";

contract ForwarderBaseUpgradeableUpgradeTest is Test {
    address internal constant _UNAUTHORIZED_CALLER = address(uint160(1));
    address internal constant _PA_OWNER = address(uint160(2));
    address internal constant _FORWARDER_OWNER = address(uint160(3));

    bytes32 internal constant _LOGIC_REF = bytes32(type(uint256).max);

    address internal _pa;
    ForwarderUpgradeableExample internal _fwdProxy;
    address internal _implV2;

    ForwarderTargetExample internal _tgt;

    function setUp() public {
        _pa = makeAddr("pa");

        _tgt = new ForwarderTargetExample();
        _fwdProxy = ForwarderUpgradeableExample(
            Upgrades.deployUUPSProxy(
                "ForwarderUpgradeableExample.sol:ForwarderUpgradeableExample",
                abi.encodeCall(ForwarderUpgradeableExample.initialize, (_pa, _LOGIC_REF, _FORWARDER_OWNER))
            )
        );

        Options memory opts;
        _implV2 = Upgrades.prepareUpgrade("ForwarderUpgradeableExample.sol:ForwarderUpgradeableExampleV2", opts);
    }

    // This test runs the openzeppelin-foundry-upgrades checks.
    function test_upgrades_safely() public {
        // `startPrank`/`stopPrank` keeps `_FORWARDER_OWNER` as the caller across the implementation deploy and the
        // `upgradeToAndCall` that `Upgrades.upgradeProxy` performs internally; a single `vm.prank` would only apply
        // to the deploy.
        vm.startPrank(_FORWARDER_OWNER);
        Upgrades.upgradeProxy(
            address(_fwdProxy),
            "ForwarderUpgradeableExample.sol:ForwarderUpgradeableExampleV2",
            abi.encodeCall(ForwarderUpgradeableExampleV2.reinitialize, ())
        );
        vm.stopPrank();
    }

    function test_upgradeToAndCall_reverts_if_the_caller_is_not_the_owner() public {
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, address(this)));
        _fwdProxy.upgradeToAndCall({
            newImplementation: _implV2, data: abi.encodeCall(ForwarderUpgradeableExampleV2.reinitialize, ())
        });
    }

    function test_upgradeToAndCall_upgrades_to_the_new_implementation() public {
        vm.prank(_FORWARDER_OWNER);
        _fwdProxy.upgradeToAndCall({
            newImplementation: _implV2, data: abi.encodeCall(ForwarderUpgradeableExampleV2.reinitialize, ())
        });

        assertEq(Upgrades.getImplementationAddress(address(_fwdProxy)), _implV2);
    }

    function test_upgradeToAndCall_emits_the_Upgraded_and_Initialized_events() public {
        vm.expectEmit(address(_fwdProxy));
        emit IERC1967.Upgraded({implementation: _implV2});

        vm.expectEmit(address(_fwdProxy));
        emit Initializable.Initialized({version: 2});

        vm.prank(_FORWARDER_OWNER);
        _fwdProxy.upgradeToAndCall({
            newImplementation: _implV2, data: abi.encodeCall(ForwarderUpgradeableExampleV2.reinitialize, ())
        });
    }
}
