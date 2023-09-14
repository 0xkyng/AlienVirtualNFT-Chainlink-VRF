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
        uint256 intelligence;
        uint256 wisdom;
        uint256 charisma;
        uint256 experience;
        string color;
        string name;
    }

    Alien[] public aliens;
    mapping(bytes32 => string)  requestToAlienName;
    mapping(bytes32 => address) requestTosender;
    mapping(bytes32 => uint256) requestTokenId;

    // Chainlink VRF variables
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    address public VRFCoordinator;
    address public LinkToken;

    //

    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash)
        VRFConsumerBase(_VRFCoordinator, _LinkToken)
        ERC721("AlienVirtualNFT", "AVN")
    {   
        VRFCoordinator = _VRFCoordinator;
        LinkToken = _LinkToken;
        keyHash = _keyhash;
        fee = 0.1 * 10**18; // 0.1 LINK
    }
    
    // Request randomness from Chainlink VRF
    function requestNewAlien(string memory name) public returns(bytes32) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK tokens");
        bytes32 requestId = requestRandomness(keyHash, fee);
        requestToAlienName[requestId] = name;
        requestTosender[requestId] = msg.sender;
        return requestId;
    }

    

}
