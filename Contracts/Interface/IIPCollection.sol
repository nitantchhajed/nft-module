// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIPCollection {
    function mint(address recipient) external payable returns (uint256);
}
