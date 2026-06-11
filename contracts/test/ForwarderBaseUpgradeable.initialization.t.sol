// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Initializable} from "@openzeppelin-contracts-5.6.1/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin-contracts-upgradeable-5.6.1/access/OwnableUpgradeable.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades-0.4.1/src/Upgrades.sol";

import {ForwarderBaseUpgradeable} from "../src/ForwarderBaseUpgradeable.sol";
import {ForwarderUpgradeableExample} from "./examples/ForwarderUpgradeableExample.sol";
import {ERC1967ProxyUnsafe} from "./helpers/ERC1967ProxyUnsafe.sol";
import {TestWithRoles} from "./helpers/TestWithRoles.sol";
import {ProtocolAdapterMock} from "./mocks/ProtocolAdapterMock.sol";

contract ForwarderBaseUpgradeableInitializationTest is TestWithRoles {
    bytes32 internal constant _LOGIC_REF = bytes32(type(uint256).max);

    address internal _pa;

    ForwarderUpgradeableExample internal _fwd;

    function setUp() public virtual {
        _pa = address(new ProtocolAdapterMock(_PA_OWNER));

        _fwd = ForwarderUpgradeableExample(
            Upgrades.deployUUPSProxy(
                "ForwarderUpgradeableExample.sol:ForwarderUpgradeableExample",
                abi.encodeCall(ForwarderUpgradeableExample.initialize, (_pa, _LOGIC_REF, _PA_OWNER))
            )
        );
    }

    function test_constructor_disables_initializers_of_the_implementation_contract() public {
        ForwarderUpgradeableExample impl = new ForwarderUpgradeableExample();
        vm.expectRevert(Initializable.InvalidInitialization.selector, address(impl));

        impl.initialize({protocolAdapter: _pa, logicRef: _LOGIC_REF, initialOwner: _FORWARDER_OWNER});
    }

    function test_initialize_reverts_if_the_protocol_adapter_address_is_zero() public {
        ForwarderUpgradeableExample uninitializedFwd = ForwarderUpgradeableExample(
            address(new ERC1967ProxyUnsafe(address(new ForwarderUpgradeableExample()), ""))
        );

        vm.expectRevert(ForwarderBaseUpgradeable.ZeroNotAllowed.selector, address(uninitializedFwd));
        uninitializedFwd.initialize({protocolAdapter: address(0), logicRef: _LOGIC_REF, initialOwner: _FORWARDER_OWNER});
    }

    function test_initialize_reverts_if_the_logic_ref_is_zero() public {
        ForwarderUpgradeableExample uninitializedFwd = ForwarderUpgradeableExample(
            address(new ERC1967ProxyUnsafe(address(new ForwarderUpgradeableExample()), ""))
        );

        vm.expectRevert(ForwarderBaseUpgradeable.ZeroNotAllowed.selector, address(uninitializedFwd));
        uninitializedFwd.initialize({protocolAdapter: _pa, logicRef: bytes32(0), initialOwner: _FORWARDER_OWNER});
    }

    function test_initialize_reverts_if_the_owner_is_zero() public {
        ForwarderUpgradeableExample uninitializedFwd = ForwarderUpgradeableExample(
            address(new ERC1967ProxyUnsafe(address(new ForwarderUpgradeableExample()), ""))
        );

        vm.expectRevert(
            abi.encodeWithSelector(OwnableUpgradeable.OwnableInvalidOwner.selector, address(0)),
            address(uninitializedFwd)
        );
        uninitializedFwd.initialize({protocolAdapter: _pa, logicRef: _LOGIC_REF, initialOwner: address(0)});
    }

    function test_initialize_reverts_on_second_call() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector, address(_fwd));
        _fwd.initialize({protocolAdapter: _pa, logicRef: _LOGIC_REF, initialOwner: _FORWARDER_OWNER});
    }
}
