// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract Astrodice is ERC721URIStorage, VRFConsumerBaseV2 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    bytes32 keyHash;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each as uint256 costs more.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    enum Planet {
        Sun, // represents 1
        Moon, // represents 2
        Mercury, // represents 3
        Mars, // represents 4
        Venus, // represents 5
        Jupiter, // represents 6
        Saturn, // represents 7
        Uranus, // represents 8
        Neptune, // represents 9
        PLuto, // represents 10
        NorthNode, // represents 11
        SouthNode // represents 12
    }

    enum Sign {
        Aries, // represents 1
        Taurus, // represents 2
        Gemini, // represents 3
        Cancer, // represents 4
        Leo, // represents 5
        Virgo, // represents 6
        Libra, // represents 7
        Scorpio, // represents 8
        Sagittarius, // represents 9
        Capricorn, // represents 10
        Aquarius, // represents 11
        Pisces // represents 12
    }

    enum House {
        First,
        Second,
        Third,
        Fourth,
        Fifth,
        Sixth,
        Seventh,
        Eighth,
        Ninth,
        Tenth,
        Eleventh,
        Twelfth
    }

    struct Reading {
        Planet planet;
        Sign sign;
        House house;
    }


    mapping(uint256 => address) private requestIdToSender;
    mapping(address => Reading) public querentToReading;

    // Events (Need to add later)
    

    constructor(
        uint64 subscriptionId,
        address vrfCoordinator,
        bytes32 _keyHash
    ) ERC721("Astrodice", "ASTRODICE") VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
        keyHash = _keyHash;
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() external returns(uint256) {
        // Will revert if subscription is not set and funded.
        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            3 // Request 3 random values.
        );

        requestIdToSender[requestId] = msg.sender;
        return requestId;
    }

    function fulfillRandomWords(
        uint256 requestId, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        // Convert randomWords to AstroValue
        Planet planet = Planet((randomWords[2] % 12) + 1);
        Sign sign = Sign((randomWords[0] % 12) + 1);
        House house = House((randomWords[1] % 12) + 1);
        

        address userAddress = requestIdToSender[requestId];
        // I think code below is erroneous
        // delete requestIdToSender[requestId]; // Clean up mapping

        _mintAstroNFT(userAddress, planet, sign, house);
    }

    function _mintAstroNFT(address userAddress, Planet planet, Sign sign, House house) private {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(userAddress, newItemId);

        querentToReading[msg.sender] = Reading(planet, sign, house);

        // Set the token URI for the newly minted token
        // You will need to create a function that generates the metadata URI based on these values
        // For this example, we'll assume a function `_tokenURI` exists that does this
        _setTokenURI(newItemId, _tokenURI(newItemId, planet, sign, house));
    }


    function _tokenURI(uint256 tokenId, Planet planet, Sign sign, House house) private view returns (string memory) {
        Reading memory reading = querentToReading[ownerOf(tokenId)];

        string memory json = Base64.encode(bytes(string(abi.encodePacked(
            '{"name": "AstroDiceReading #', Strings.toString(tokenId), 
            '", "description": "Your unique astrological reading.", ',
            '"attributes": [',
                '{"trait_type": "Planet", "value": "', _getPlanetName(reading.planet), '"},',
                '{"trait_type": "Sign", "value": "', _getSignName(reading.sign), '"},',
                '{"trait_type": "House", "value": "', _getHouseName(reading.house), '"}',
            ']}'
        ))));

        return string(abi.encodePacked("data:application/json;base64,", json));
}

    function _getPlanetName(Planet planet) private pure returns (string memory) {
    // Use a static array of strings to hold the names for each enum value
    string[12] memory planetNames = [
        "Sun",
        "Moon",
        "Mercury",
        "Mars",
        "Venus",
        "Jupiter",
        "Saturn",
        "Uranus",
        "Neptune",
        "Pluto",
        "NorthNode",
        "SouthNode"
    ];

    return planetNames[uint(planet)]; // Convert enum to uint to index the array
}

function _getSignName(Sign sign) private pure returns (string memory) {
    string[12] memory signNames = [
        "Aries",
        "Taurus",
        "Gemini",
        "Cancer",
        "Leo",
        "Virgo",
        "Libra",
        "Scorpio",
        "Sagittarius",
        "Capricorn",
        "Aquarius",
        "Pisces"
    ];

    return signNames[uint(sign)];
}

function _getHouseName(House house) private pure returns (string memory) {
    string[12] memory houseNames = [
        "First",
        "Second",
        "Third",
        "Fourth",
        "Fifth",
        "Sixth",
        "Seventh",
        "Eighth",
        "Ninth",
        "Tenth",
        "Eleventh",
        "Twelfth"
    ];

    return houseNames[uint(house)];
}

}