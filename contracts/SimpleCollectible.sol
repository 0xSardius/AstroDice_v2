//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SimpleCollectible is ERC721 {

    constructor() public ERC721 ("AstroDice Demo", "ADD") {
        
    }
}