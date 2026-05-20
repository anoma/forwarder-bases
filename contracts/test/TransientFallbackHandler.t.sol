// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC1155Receiver} from "@openzeppelin-contracts-5.6.1/token/ERC1155/IERC1155Receiver.sol";
import {IERC721Receiver} from "@openzeppelin-contracts-5.6.1/token/ERC721/IERC721Receiver.sol";
import {Test} from "forge-std-1.16.1/src/Test.sol";

import {IFallbackHandler} from "../src/interfaces/IFallbackHandler.sol";
import {TransientFallbackHandler} from "../src/TransientFallbackHandler.sol";
import {ERC1155Example} from "./examples/ERC1155.e.sol";
import {ERC721Example} from "./examples/ERC721.e.sol";

contract TransientFallbackHandlerTest is Test {
    bytes4 internal constant _UNREGISTERED = bytes4(0);

    TransientFallbackHandler internal _handler;

    ERC721Example internal _erc721;
    ERC1155Example internal _erc1155;

    function setUp() public {
        _handler = new TransientFallbackHandler();

        _erc721 = new ERC721Example();
        _erc1155 = new ERC1155Example();
    }

    function testFuzz_registerSelector_registers_a_selector_and_the_associated_magic_number(
        bytes4 selector,
        bytes4 magicNumber
    ) public {
        vm.assume(magicNumber != _UNREGISTERED);

        _handler.registerSelector({selector: selector, magicNumber: magicNumber});

        assertEq(_handler.lookupMagicNumber(selector), magicNumber, "An unexpected magic number got returned");
    }

    function testFuzz_registerSelector_reregisters_a_selector_with_the_same_magic_number(
        bytes4 selector,
        bytes4 magicNumber
    ) public {
        vm.assume(magicNumber != _UNREGISTERED);

        _handler.registerSelector({selector: selector, magicNumber: magicNumber});

        _handler.registerSelector({selector: selector, magicNumber: magicNumber});

        assertEq(_handler.lookupMagicNumber(selector), magicNumber, "An unexpected magic number got returned");
    }

    function testFuzz_registerSelector_reregisters_a_selector_with_a_different_magic_number(
        bytes4 selector,
        bytes4 magicNumber,
        bytes4 differentMagicNumber
    ) public {
        vm.assume(magicNumber != _UNREGISTERED);
        vm.assume(differentMagicNumber != _UNREGISTERED);

        _handler.registerSelector({selector: selector, magicNumber: magicNumber});
        _handler.registerSelector({selector: selector, magicNumber: differentMagicNumber});

        assertEq(_handler.lookupMagicNumber(selector), differentMagicNumber, "An unexpected magic number got returned");
    }

    function test_handleFallback_handles_onERC721Received_callbacks() public {
        bytes4 onERC721ReceivedSelector = IERC721Receiver.onERC721Received.selector;

        _handler.registerSelector({selector: onERC721ReceivedSelector, magicNumber: onERC721ReceivedSelector});
        _erc721.mint({to: address(_handler), tokenId: 0});
    }

    function test_handleFallback_handles_onERC1155Received_callback() public {
        bytes4 onERC1155ReceivedSelector = IERC1155Receiver.onERC1155Received.selector;

        _handler.registerSelector({selector: onERC1155ReceivedSelector, magicNumber: onERC1155ReceivedSelector});
        _erc1155.mint({to: address(_handler), id: 0, amount: 1});
    }

    function test_handleFallback_emits_FallbackHandled_event(bytes4 selector, bytes4 magicNumber) public {
        vm.assume(magicNumber != _UNREGISTERED);

        _handler.registerSelector({selector: selector, magicNumber: magicNumber});

        bytes memory data = abi.encodeWithSelector(selector, uint256(42), keccak256("payload"));

        vm.expectEmit(address(_handler));
        emit IFallbackHandler.FallbackHandled({sender: address(this), selector: selector, data: data});

        // solhint-disable-next-line avoid-low-level-calls
        (bool success,) = address(_handler).call(data);
        assertTrue(success, "fallback call failed");
    }

    function test_handleFallback_reverts_on_callback_from_unregistered_selector() public {
        bytes4 onERC721ReceivedSelector = IERC721Receiver.onERC721Received.selector;

        assertEq(_handler.lookupMagicNumber(onERC721ReceivedSelector), bytes4(0));

        vm.expectRevert(
            abi.encodeWithSelector(
                TransientFallbackHandler.UnregisteredSelector.selector, onERC721ReceivedSelector, bytes4(0)
            ),
            address(_handler)
        );
        _erc721.mint({to: address(_handler), tokenId: 0});
    }

    function testFuzz_handleFallback_returns_the_magic_number_as_raw_return_data(bytes4 selector, bytes4 magicNumber)
        public
    {
        vm.assume(magicNumber != _UNREGISTERED);

        _handler.registerSelector({selector: selector, magicNumber: magicNumber});

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returnData) = address(_handler).call(abi.encodeWithSelector(selector));
        assertTrue(success, "fallback call failed");
        assertEq(abi.decode(returnData, (bytes4)), magicNumber, "fallback returned an unexpected magic number");
    }

    function test_registerSelector_distinct_selectors_do_not_collide(
        bytes4 selectorA,
        bytes4 magicNumberA,
        bytes4 selectorB,
        bytes4 magicNumberB
    ) public {
        vm.assume(selectorA != selectorB);

        _handler.registerSelector({selector: selectorA, magicNumber: magicNumberA});
        _handler.registerSelector({selector: selectorB, magicNumber: magicNumberB});

        assertEq(_handler.lookupMagicNumber(selectorA), magicNumberA, "selectorA returned an unexpected magic number");
        assertEq(_handler.lookupMagicNumber(selectorB), magicNumberB, "selectorB returned an unexpected magic number");
    }

    function testFuzz_registerSelector_distinct_selectors_do_not_collide(
        bytes4 selectorA,
        bytes4 magicNumberA,
        bytes4 selectorB,
        bytes4 magicNumberB
    ) public {
        vm.assume(selectorA != selectorB);
        vm.assume(magicNumberA != bytes4(0));
        vm.assume(magicNumberB != bytes4(0));

        _handler.registerSelector({selector: selectorA, magicNumber: magicNumberA});
        _handler.registerSelector({selector: selectorB, magicNumber: magicNumberB});

        assertEq(_handler.lookupMagicNumber(selectorA), magicNumberA, "selectorA returned an unexpected magic number");
        assertEq(_handler.lookupMagicNumber(selectorB), magicNumberB, "selectorB returned an unexpected magic number");
    }

    function test_registerSelector_with_zero_magic_number_disables_a_previously_registered_callback() public {
        bytes4 onERC721ReceivedSelector = IERC721Receiver.onERC721Received.selector;

        _handler.registerSelector({selector: onERC721ReceivedSelector, magicNumber: onERC721ReceivedSelector});
        assertEq(_handler.lookupMagicNumber(onERC721ReceivedSelector), onERC721ReceivedSelector);

        _handler.registerSelector({selector: onERC721ReceivedSelector, magicNumber: bytes4(0)});
        assertEq(_handler.lookupMagicNumber(onERC721ReceivedSelector), bytes4(0));

        vm.expectRevert(
            abi.encodeWithSelector(
                TransientFallbackHandler.UnregisteredSelector.selector, onERC721ReceivedSelector, bytes4(0)
            ),
            address(_handler)
        );
        _erc721.mint({to: address(_handler), tokenId: 0});
    }
}
