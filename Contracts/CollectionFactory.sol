// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Collections/ArtistCollection.sol";
import "./Collections/UserCollection.sol";
import "./Beacon-proxy/VaultBeacon.sol";
import "./Interface/IAddressManager.sol";

/**
 * @title CollectionFactory
 * @dev Factory contract for creating artist and user collections
 */
contract CollectionFactory {
    IAddressManager public addressManager;
    VaultBeacon private artistBeacon;
    VaultBeacon private userBeacon;

    /**
     * @dev Constructor sets the address manager
     * @param addressManager_ The address of the AddressManager contract
     */
    constructor(address addressManager_) {
        addressManager = IAddressManager(addressManager_);
    }

    /**
     * @dev Sets up the beacon contracts
     * @custom:na-natspec setAddresses() should only be callable once
     */
    function setAddresses() external {
        require(msg.sender == addressManager.getContractAddress("NFT_MODULE"), "Caller is not NFT_MODULE");
        artistBeacon = new VaultBeacon(
            addressManager.getContractAddress("ARTIST_IMPL")
        );
        userBeacon = new VaultBeacon(
            addressManager.getContractAddress("USER_IMPL")
        );
    }

    /**
     * @dev Creates a new IP collection
     * @custom:na-natspec createIPCollection() should only be callable by NFT_MODULE
     */
    function createIPCollection(
        address initialOwner,
        string calldata name,
        string calldata symbol,
        string calldata baseTokenURI,
        uint256 mintPrice,
        uint256 maxSupply
    ) external returns (address) {
        require(
            msg.sender == addressManager.getContractAddress("NFT_MODULE"),
            "Caller is not NFT-MODULE"
        );
        BeaconProxy artistProxy = new BeaconProxy(
            address(artistBeacon),
            abi.encodeWithSelector(
                ArtistNFTCollection(address(0)).initialize.selector,
                initialOwner,
                name,
                symbol,
                baseTokenURI,
                mintPrice,
                maxSupply,
                addressManager.getContractAddress("NFT_MODULE")
            )
        );
        return address(artistProxy);
    }

    /**
     * @dev Creates a new user collection
     * @custom:na-natspec createCollection() should only be callable by NFT_MODULE
     */
    function createCollection(
        address initialOwner,
        string calldata name,
        string calldata symbol
    ) external returns (address) {
        require(
            msg.sender == addressManager.getContractAddress("NFT_MODULE"),
            "Caller is not NFT-MODULE"
        );
        BeaconProxy userProxy = new BeaconProxy(
            address(userBeacon),
            abi.encodeWithSelector(
                UserCollection(address(0)).initialize.selector,
                initialOwner,
                name,
                symbol
            )
        );
        return address(userProxy);
    }
}