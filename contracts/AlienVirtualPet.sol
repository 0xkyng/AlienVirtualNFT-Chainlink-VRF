
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

 struct Alien {
        uint256 intelligence;
        uint256 wisdom;
        uint256 rarity;
        uint256 charisma;
        uint256 strength;
        uint256 height;
    }

contract AlienVirtualPet is
    ERC721("AlienVirtualPet", "AVP"),
    VRFConsumerBaseV2,
    ConfirmedOwner
{
    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests;
    Alien[] public aliens;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    //  GOERLI VRF SETUP
    bytes32 keyHash =
        0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint32 callbackGasLimit = 2500000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint64 subscriptionId;

    address _coordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;

    VRFCoordinatorV2Interface COORDINATOR =
        VRFCoordinatorV2Interface(_coordinator);

    constructor(
        uint64 _subID
    ) VRFConsumerBaseV2(_coordinator) ConfirmedOwner(msg.sender) {
        subscriptionId = _subID;
    }

    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;

        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;

        uint tokenID = aliens.length;
        uint _word = _randomWords[0];

        uint intelligence = ((_word % 100) % 18);
        uint wisdom = (((_word % 10000) / 100) % 18);
        uint rarity = (((_word % 1000000) / 10000) % 18);
        uint charisma = (((_word % 100000000) / 1000000) % 18);
        uint strength = (((_word % 10000000000) / 100000000) % 18);
        uint height = (((_word % 1000000000000) / 10000000000) % 18);

        aliens.push(
            Alien(
                  intelligence,
                  wisdom,
                  rarity,
                  charisma,
                  strength,
                  height
            )
        );

        _safeMint(msg.sender, tokenID);
    }
}
