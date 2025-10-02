// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title TestDynamicNFT
 * @dev Simplified Test NFT contract for basic functionality testing
 */
contract TestDynamicNFT is ERC721 {
    using Strings for uint256;

    // Storage
        uint256 private _tokenIdCounter;
            uint256 private _version = 0;

    // Simplified NFT State
    struct NFTState {
        uint256 userActionCount;
        string currentWeather;
        string currentTimeOfDay;
        uint256 createdAt;
    }

    // Mappings
    mapping(uint256 => NFTState) public nftStates;

    // Events
    event NFTMinted(uint256 indexed tokenId, address indexed owner);
        event NFTUpdated(uint256 indexed tokenId, string updateType, string newValue);

    // Predefined weather and time options for testing
    string[] private weatherOptions = ["sunny", "rainy", "cloudt", "snowy", "foggy"];
    string[] private timeOptions = ["morning", "afternoon", "evening", "night"];

    constructor() ERC721("Simple Dynamic NFT", "SDYNFT") {}

   /**
     * @dev Mint a new NFT - anyone can mint for testing
     */
    function mint(address to) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _safeMint(to, tokenId);

        // Initialize NFT state with random values
        nftStates[tokenId] = NFTState({
            userActionCount: 0,
            currentWeather: weatherOptions[_pseudoRandom(tokenId, "weather") % weatherOptions.length],
            currentTimeOfDay: timeOptions[_pseudoRandom(tokenId, "time") % timeOptions.length],
            createdAt: block.timestamp
        });

        emit NFTMinted(tokenId, to);
        return tokenId;
    }

    /**
     * @dev Update weather - anyone can call for testing
     */
    function updateWeather(uint256 tokenId) external {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        string memory newWeather = weatherOptions[_pseudoRandom(block.timestamp, "weather") % weatherOptions.length];
        nftStates[tokenId].currentWeather = newWeather;

        emit NFTUpdated(tokenId, "weather", newWeather);
    }

    /**
     * @dev Update time of day - anyone can call for testing
     */
    function updateTimeOfDay(uint256 tokenId) external {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        string memory newTimeOfDay = timeOptions[_pseudoRandom(block.timestamp, "time") % timeOptions.length];
        nftStates[tokenId].currentTimeOfDay = newTimeOfDay;

        emit NFTUpdated(tokenId, "timeOfDay", newTimeOfDay);
    }

    /**
     * @dev Perform user action - anyone can call for testing
     */
    function performUserAction(uint256 tokenId) external {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        nftStates[tokenId].userActionCount++;

        emit NFTUpdated(tokenId, "userAction", Strings.toString(nftStates[tokenId].userActionCount));
    }

    function _pseudoRandom(uint256 seed, string memory salt) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, seed, salt)));
    }
}