// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Admin address:0x9cdf5ce3c9ea71ecc8fb7c3a17ed7b6c74f9c5f0

contract AlienVirtualNFT is ERC721URIStorage, Ownable, VRFConsumerBase {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Alien {
        uint256 energy;
        uint256 speed;
        uint256 rarity;
        string color;
        string alienType;
    }

    Alien[] public aliens;

    // Chainlink VRF variables
    bytes32 internal keyHash;
    uint256 internal fee;

    constructor(
        address vrfCoordinator,
        address linkToken,
        bytes32 vrfKeyHash,
        uint256 vrfFee
    )
        ERC721("AlienVirtualNFT", "AVN")
        VRFConsumerBase(vrfCoordinator, linkToken)
    {
        keyHash = vrfKeyHash;
        fee = vrfFee;
    }

    // Request randomness from Chainlink VRF
    function getRandomness() external onlyOwner() returns(bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK tokens");
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestedId, uint256 randomness) internal override {
        uint256 index = randomness % aliens.length;

        // Mint the Alien with the selected traits
        _mint(msg.sender, index);
    }

}
