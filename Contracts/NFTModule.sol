// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Interface/ICollectionFactory.sol";
import "./Interface/ICollection.sol";
import "./Interface/IIPCollection.sol";
import "./Interface/ICollectionToken.sol";
import "./Interface/IAddressManager.sol";

/**
 * @title NFTModuleUpgradeable
 * @dev This contract manages NFT collections and minting operations
 * @custom:security-contact security@example.com
 */
contract NFTModule is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {
    address public PROTOCOL_COLLECTION_ADDRESS;
    IAddressManager public addressManager;
    ICollectionFactory public collectionFactory;
    ICollectionToken public collectionToken;
    
    event CollectionCreated(address indexed creator, address indexed collectionAddress);
    event IPCollectionCreated(address indexed creator, address indexed collectionAddress, uint256 collectionTokenID);
    event NFTMinted(address indexed collectionAddress, address indexed recipient, uint256 tokenId);

    /**
     * @dev Initializes the contract
     * @param addressManager_ The address of the AddressManager contract
     */
    function initialize(address addressManager_) external initializer {
        __Ownable_init(_msgSender());
        __ReentrancyGuard_init();
        __Pausable_init();
        addressManager = IAddressManager(addressManager_);
    }

    /**
     * @dev Sets the addresses of dependent contracts
     * @custom:na-natspec setAddresses() should only be callable at initialization
     */
    function setAddresses() internal onlyOwner {
        collectionFactory = ICollectionFactory(addressManager.getContractAddress("COLLECTION_FACTORY"));
        PROTOCOL_COLLECTION_ADDRESS = addressManager.getContractAddress("PROTOCOL_COLLECTION");
        collectionToken = ICollectionToken(addressManager.getContractAddress("COLLECTION_TOKEN"));
        collectionFactory.setAddresses();
    }

    /**
     * @dev Creates a new IP collection
     * @param name The name of the collection
     * @param symbol The symbol of the collection
     * @param baseTokenURI The base token URI for the collection
     * @param mintPrice The minting price for NFTs in this collection
     * @param maxSupply The maximum supply of NFTs in this collection
     * @custom:na-natspec  createIPCollection() should be protected against reentrancy
     * @custom:na-natspec createIPCollection() should be pausable
     */
    function createIPCollection(
        string calldata name,
        string calldata symbol,
        string calldata baseTokenURI,
        uint256 mintPrice,
        uint256 maxSupply
        // uint256 LicenseTermID
        // 
    ) external nonReentrant whenNotPaused {
        address ipCollection = collectionFactory.createIPCollection(
            _msgSender(),
            name,
            symbol,
            baseTokenURI,
            mintPrice,
            maxSupply
        );
        require(ipCollection != address(0), "Collection creation failed");

        uint256 collectionTokenID = collectionToken.safeMint(_msgSender(), ipCollection, symbol);

        //TODO: Register Collection as IP 
        //TODO: Attach Licenst Terms

        emit IPCollectionCreated(_msgSender(), ipCollection, collectionTokenID);
    }

    /**
     * @dev Creates a new user collection
     * @param name The name of the collection
     * @param symbol The symbol of the collection
     * @return userCollection The address of the created collection
     * @custom:na-natspec  createCollection() should be protected against reentrancy
     * @custom:na-natspec  createCollection() should be pausable
     */
    function createCollection(
        string calldata name,
        string calldata symbol
    ) external nonReentrant whenNotPaused returns (address userCollection) {
        userCollection = collectionFactory.createCollection(_msgSender(), name, symbol);
        emit CollectionCreated(_msgSender(), userCollection);
    }

    /**
     * @dev Mints an NFT from a specific collection
     * @param collectionAddress The address of the collection to mint from
     * @param recipient The address to receive the minted NFT
     * @param metadataURI The metadata URI for the minted NFT
     * @return tokenId The ID of the minted NFT
     * @custom:na-natspec  mintFromCollection() should be protected against reentrancy
     * @custom:na-natspec  mintFromCollection() should be pausable
     */
    function mintFromCollection(
        address collectionAddress,
        address recipient,
        string calldata metadataURI
    ) public nonReentrant whenNotPaused returns (uint256 tokenId) {
        require(collectionAddress != address(0) && recipient != address(0), "Invalid address");

        tokenId = ICollection(collectionAddress).safeMint(recipient, metadataURI);
        emit NFTMinted(collectionAddress, recipient, tokenId);
    }

    /**
     * @dev Mints an NFT from the protocol collection
     * @param recipient The address to receive the minted NFT
     * @param metadataURI The metadata URI for the minted NFT
     * @return The ID of the minted NFT
     * @custom:na-natspec  mintFromProtocolCollection() should be pausable
     */
    function mintFromProtocolCollection(
        address recipient,
        string calldata metadataURI
    ) external whenNotPaused returns (uint256) {
        return mintFromCollection(PROTOCOL_COLLECTION_ADDRESS, recipient, metadataURI);
    }

    /**
     * @dev Mints an IP NFT from an IP collection
     * @param artistCollection The address of the artist's collection
     * @param recipient The address to receive the minted NFT
     * @return The address of the artist's collection and the ID of the minted NFT
     * @custom:na-natspec  mintIPfromIPCollection() should be pausable
     */
    function mintIPfromIPCollection(
        address artistCollection,
        address recipient
    ) public whenNotPaused returns (address, uint256) {
        uint256 tokenId = IIPCollection(artistCollection).mint(recipient);

        /* TODO: 1. Register it as an IP.
                 2. Attach the Artist Collection License terms to IP
        */

        return (artistCollection, tokenId);
    }

    /**
     * @dev Retrieves information about an artist's collection
     * @param artistCollectionAddress The address of the artist's collection
     * @return The collection token ID and symbol
     */
    function getArtistCollectionInfo(address artistCollectionAddress) external view returns (uint256, string memory) {
        return collectionToken.tokenCollection(artistCollectionAddress);
    }

    /**
     * @dev Pauses all contract functions
     * @custom:na-natspec pause() should only be callable by the contract owner
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses all contract functions
     * @custom:na-natspec unpause() should only be callable by the contract owner
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Recovers any ERC20 tokens sent to the contract by mistake
     * @param tokenAddress The address of the ERC20 token to recover
     * @param tokenAmount The amount of tokens to recover
     * @custom:na-natspec  recoverERC20() should only be callable by the contract owner
     */
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }

    /**
     * @dev Recovers any Ether sent to the contract by mistake
     * @custom:na-natspec recoverEther() should only be callable by the contract owner
     */
    function recoverEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}