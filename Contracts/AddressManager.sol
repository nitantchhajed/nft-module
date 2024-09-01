// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title AddressManager
 * @dev Manages contract addresses with batch update capability
 */
contract AddressManager is Ownable {
    mapping(string => address) private contractAddresses;
    string[] private contractNames;

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @dev Sets a single contract address
     * @param contractName The name of the contract
     * @param _address The address of the contract
     */
    function setContractAddress(string memory contractName, address _address) public onlyOwner {
        _setContractAddress(contractName, _address);
    }

    /**
     * @dev Sets multiple contract addresses at once
     * @param _contractNames Array of contract names
     * @param _addresses Array of contract addresses
     */
    function setBatchContractAddresses(
        string[] calldata _contractNames,
        address[] calldata _addresses
    ) external onlyOwner {
        require(_contractNames.length == _addresses.length, "Arrays length mismatch");
        
        uint256 length = _contractNames.length;
        for (uint256 i = 0; i < length; i++) {
            _setContractAddress(_contractNames[i], _addresses[i]);
        }
    }

    /**
     * @dev Internal function to set a contract address
     * @param contractName The name of the contract
     * @param _address The address of the contract
     */
    function _setContractAddress(string memory contractName, address _address) private {
        require(_address != address(0), "Invalid address");
        
        if (contractAddresses[contractName] == address(0)) {
            contractNames.push(contractName);
        }
        
        contractAddresses[contractName] = _address;
    }

    /**
     * @dev Gets a contract address
     * @param contractName The name of the contract
     * @return The address of the contract
     */
    function getContractAddress(string memory contractName) external view returns (address) {
        return contractAddresses[contractName];
    }

    /**
     * @dev Gets all contract names
     * @return An array of all contract names
     */
    function getAllContractNames() external view returns (string[] memory) {
        return contractNames;
    }

    /**
     * @dev Gets all contract addresses
     * @return names An array of all contract names
     * @return addresses An array of all contract addresses
     */
    function getAllContractAddresses() external view returns (string[] memory names, address[] memory addresses) {
        uint256 length = contractNames.length;
        addresses = new address[](length);
        
        for (uint256 i = 0; i < length; i++) {
            addresses[i] = contractAddresses[contractNames[i]];
        }
        
        return (contractNames, addresses);
    }
}