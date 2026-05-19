// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC721} from "@openzeppelin-contracts-5.6.1/token/ERC721/ERC721.sol";

contract ERC721Example is ERC721 {
    constructor() ERC721("Example", "XMP") {}

    function mint(address to, uint256 tokenId) external {
        _safeMint({to: to, tokenId: tokenId});
    }
}
