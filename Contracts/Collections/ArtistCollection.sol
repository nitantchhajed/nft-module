// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract ArtistNFTCollection is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    ERC721PausableUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    uint256 private _nextTokenId;

    constructor() {
        _disableInitializers();
    }

    uint256 public MAX_SUPPLY;
    uint256 public _mintPrice;
    address public NFT_MODULE;
    bool public mintPaused;
    string private _baseTokenURI;

    mapping(address => uint256) private _mintedCount;

    function initialize(
        address initialOwner,
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        uint256 mintPrice,
        uint256 maxSupply,
        address nft_module
    ) public initializer {
        __ERC721_init(name, symbol);
        __Ownable_init(initialOwner);
        __ERC721URIStorage_init();
        // __UUPSUpgradeable_init();
        _baseTokenURI = baseTokenURI;
        _mintPrice = mintPrice;
        MAX_SUPPLY = maxSupply;
        NFT_MODULE = nft_module;
    }

    function mint(address recipient) external payable nonReentrant returns(uint256){
        require(msg.sender == NFT_MODULE, "Caller is not NFT Module");
        require(!mintPaused, "Minting is paused");
        require(_nextTokenId < MAX_SUPPLY, "Would exceed max supply");
        require(msg.value >= _mintPrice, "Insufficient payment");

       
        uint256 newTokenId = _nextTokenId;
        _safeMint(recipient, newTokenId);
         _nextTokenId++;
        return newTokenId;
        
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function setMintPrice(uint256 mintPrice) external onlyOwner {
        _mintPrice = mintPrice;
    }

    function toggleMintPaused() external onlyOwner {
        mintPaused = !mintPaused;
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function totalSupply() public view returns (uint256) {
        return _nextTokenId;
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721Upgradeable, ERC721PausableUpgradeable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
