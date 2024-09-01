// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAddressManager {
    function getContractAddress(
        string memory contractName
    ) external view returns (address);

    function setContractAddress(
        string memory contractName,
        address _address
    ) external;
}
