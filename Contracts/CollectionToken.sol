// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Interface/IAddressManager.sol";

contract CollectionToken is ERC721 {
    IAddressManager public addressManager;
    uint256 private _nextTokenId;

    struct Collections {
        uint256 tokenId;
        string collectionSymbol;
    }

    mapping(address => Collections) private _tokenCollections;

    constructor(address _addressManager) ERC721("KOR-CollectionToken", "KCT") {
        addressManager = IAddressManager(_addressManager);
    }

    function safeMint(address to, address artistCollection, string memory collectionSymbol) public returns(uint256){
        require(
            msg.sender == addressManager.getContractAddress("NFT_MODULE"),
            "Caller is not NFT-MODULE"
        );
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenCollection(tokenId, artistCollection,collectionSymbol );
        return (tokenId);
    }

    function _setTokenCollection(
        uint256 tokenId,
        address artistCollection,
        string memory collectionSymbol
    ) private {
        _tokenCollections[artistCollection] = Collections(tokenId, collectionSymbol);
    }

    function tokenCollection(
        address artistCollection
    ) external view returns (uint256, string memory) {
        Collections memory collectionInfo = _tokenCollections[artistCollection];
        return (collectionInfo.tokenId, collectionInfo.collectionSymbol);
    }
}
