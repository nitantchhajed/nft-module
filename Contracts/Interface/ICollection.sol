// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICollection {
    function safeMint(address recipient, string memory uri) external returns (uint256);
}
