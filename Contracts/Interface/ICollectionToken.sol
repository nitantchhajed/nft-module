// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICollectionToken {
    function safeMint(address to, address artistCollection, string memory symbol) external returns(uint256);

    function tokenCollection(
        address artistCollection
    ) external view returns (uint256, string memory);
}
