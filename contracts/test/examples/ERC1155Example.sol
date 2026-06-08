// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC1155} from "@openzeppelin-contracts-5.6.1/token/ERC1155/ERC1155.sol";

contract ERC1155Example is ERC1155 {
    constructor() ERC1155("") {}

    function mint(address to, uint256 id, uint256 amount) external {
        _mint({to: to, id: id, value: amount, data: ""});
    }
}
