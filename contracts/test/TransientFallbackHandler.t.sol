// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC721Receiver} from "@openzeppelin-contracts-5.6.1/token/ERC721/IERC721Receiver.sol";
import {Test} from "forge-std-1.16.1/src/Test.sol";

import {TransientFallbackHandler} from "../src/TransientFallbackHandler.sol";
import {ERC721Example} from "./examples/ERC721.e.sol";

contract TransientFallbackHandlerTest is Test {
    TransientFallbackHandler internal _handler;

    ERC721Example internal _erc721;

    function setUp() public {
        _handler = new TransientFallbackHandler();

        _erc721 = new ERC721Example();
    }

    function test_registerCallback_registers_a_selector_and_the_associated_magic_number() public {
        bytes4 selector = 0xdead1234;
        bytes4 magicNumber = 0xbeef5678;

        _handler.registerSelector({selector: selector, magicNumber: magicNumber});

        assertEq(_handler.lookupMagicNumber(selector), magicNumber, "An unexpected magic number got returned");
    }

    function test_registerCallback_reregisters_a_selector_with_the_same_magic_number() public {
        bytes4 selector = 0xdead1234;
        bytes4 magicNumber = 0xbeef5678;

        _handler.registerSelector({selector: selector, magicNumber: magicNumber});

        _handler.registerSelector({selector: selector, magicNumber: magicNumber});

        assertEq(_handler.lookupMagicNumber(selector), magicNumber, "An unexpected magic number got returned");
    }

    function test_registerCallback_reregisters_a_selector_with_a_different_magic_number() public {
        bytes4 selector = 0xdead1234;
        bytes4 magicNumber = 0xbeef5678;

        _handler.registerSelector({selector: selector, magicNumber: magicNumber});

        bytes4 differentMagicNumber = 0xcafe5678;

        _handler.registerSelector({selector: selector, magicNumber: differentMagicNumber});

        assertEq(_handler.lookupMagicNumber(selector), differentMagicNumber, "An unexpected magic number got returned");
    }

    function test_handleFallback_handles_callbacks() public {
        bytes4 onERC721ReceivedSelector = IERC721Receiver.onERC721Received.selector;

        _handler.registerSelector({selector: onERC721ReceivedSelector, magicNumber: onERC721ReceivedSelector});
        _erc721.mint({to: address(_handler), tokenId: 0});
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
}
