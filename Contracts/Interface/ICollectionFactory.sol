// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICollectionFactory {
    function createCollection(
        address initialOwner,
        string memory name,
        string memory symbol
    ) external returns (address);

    function createIPCollection(
        address initialOwner,
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        uint256 mintPrice,
        uint256 maxSupply
    ) external returns (address);

    function setAddresses() external; 
}
