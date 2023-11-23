//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract AstroDice is ERC721, VRYConsumerBaseV2 {

    enum Sign { Aries, Taurus, Gemini, Cancer, Leo, Virgo, Libra, Scorpio, Sagittarius, Capricorn, Aquarius, Pisces }
    enum Planet { Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, Pluto, NorthNode, SouthNode }
    enum House { First, Second, Third, Fourth, Fifth, Sixth, Seventh, Eighth, Ninth, Tenth, Eleventh, Twelfth }

    // State variables
    uint64 s_subscriptionId;
    address s_owner;
    VRFCoordinatorV2Interface COORDINATOR;
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    bytes32 s_keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  3;

    constructor() ERC721("AstroDice", "AD") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}