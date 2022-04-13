// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC721/ERC721.sol";
import "./ERC721URIStorage.sol";
import "./Ownable.sol";
import "./Counters.sol";

contract CasinoRoyal is ERC721, ERC721URIStorage, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    mapping (string => uint) existingURIs;

    uint public mintPrice; 
    uint public totalSupply;
    uint public maxSupply;
    uint public maxPerWallet;
    bool public isPublicMintEnabled;
    string internal baseTokenUri;
    address payable public withdrawWallet;
    mapping (address => uint256) public walletMints;
    string public ipfsURI;
    
    constructor() ERC721("CasinoRoyal", "CR52") {}

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    // These functions can only been executed by the owner of the contract.

    function setMintPrice(uint _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

    function setTotalSupply(uint _totalSupply) external onlyOwner {
        totalSupply = _totalSupply;
    }

    function setMaxSupply(uint _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    function setMaxPerWaller(uint _maxPerWallet) external onlyOwner {
        maxPerWallet = _maxPerWallet;
    }

    function setIsPublicMintEnabled(bool isPublicMintEnabled_) external onlyOwner {
        isPublicMintEnabled = isPublicMintEnabled_;
    }

    function setBaseTokenUri(string calldata baseTokenUri_) external onlyOwner {
        baseTokenUri = baseTokenUri_;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWallet.call{ value:address(this).balance }('');
        require(success, 'withdraw failed');
    }    

    // There are public function

    function count() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    function tokenURI(uint256 tokenId_) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId_), 'TokenID Required');
        return string(abi.encodePacked(baseTokenUri, Strings.toString(tokenId_), ".json"));
    }

    function baseTokenURI() public view returns (string memory) {
        return string(abi.encodePacked(baseTokenUri));
    }

    function mint(uint256 quantity_) public payable {

        require(mintPrice > 0, "Mint price required");
        require(totalSupply > 0, "Total Supply required");
        require(maxSupply > 0, "Max Supply required");
        require(maxPerWallet > 0, "Max Per Wallet required");

        require(isPublicMintEnabled, 'Minting not enabled');
        require(msg.value == quantity_ * mintPrice, 'Wrong mint value');
        require(totalSupply + quantity_ <= maxSupply, 'Sold out');
        require(walletMints[msg.sender] + quantity_ <= maxPerWallet, 'exceed max per wallet');
        
        for(uint256 i = 0; i < quantity_; i++) {
            uint256 newTokenId = totalSupply + 1;
            totalSupply++;
            walletMints[msg.sender] = newTokenId;
            _tokenIdCounter.increment();
            _safeMint(msg.sender, newTokenId);
        }
    }


}
