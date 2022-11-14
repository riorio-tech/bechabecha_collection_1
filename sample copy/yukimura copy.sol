// SPDX-License-Identifier: MIT
// Northern Lights by yuk6ra

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NorthernLights is ERC721URIStorage, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    uint256 public constant MAX_SUPPLY = 150;

    uint256 public mintPrice = 0.01 ether;
    uint256 public maxPerWallet = 2;
    bool public whitelistSale = false;
    string public description;

    mapping (address => uint256) public mintedPerWallet;
    mapping (address => bool) public whitelist;
    


    Counters.Counter private _tokenId;

    constructor() ERC721("NorthernLights", "NLIGHTS") {}


    function addWhitelist(address[] calldata _addresses) external onlyOwner{
        for (uint i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = true;
        }
    }

    function setMintPrice(uint256 _newPrice) external onlyOwner {
        mintPrice = _newPrice;
    }

    function setMaxPerWallet(uint256 _newQuantity) external onlyOwner {
        maxPerWallet = _newQuantity;
    }

    function setWhitelistSale(bool _bool) external onlyOwner{
        whitelistSale = _bool;
    }    

    function withdraw() external onlyOwner{
        require(address(this).balance > 0, 'No balance');
        require(payable(msg.sender).send(address(this).balance));
    }

    function reservedMint(uint256 _mintAmount) external onlyOwner {
        require(_tokenId.current() + _mintAmount <= MAX_SUPPLY, "Sold out");

        for (uint256 i = 0; i < _mintAmount; i++){
            _safeMint(msg.sender, _tokenId.current());
            _tokenId.increment();
        }
    }

    function mintNFT() public payable {
        require(whitelistSale, "Mint is paused");
        require(whitelist[msg.sender], "No whitelist");
        uint256 tokenId = _tokenId.current();
        require(tokenId < MAX_SUPPLY, "Sold out");
        require(mintedPerWallet[msg.sender] < maxPerWallet, "Already minted max quantity per wallet");
        require(msg.value >= mintPrice, "Must send the mint price");

        _safeMint(msg.sender, tokenId);
        mintedPerWallet[msg.sender] += 1;
        _tokenId.increment();
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "NorthernLights: Nonexistent token");
        return dataURI(tokenId);
    }

    /**
     * @notice Generate metadata for TokenURI.
     */
    function dataURI(uint256 tokenId) public view returns(string memory){
        require(_exists(tokenId), "NorthernLights: Nonexistent token");
        string memory name = string(abi.encodePacked('Northern Lights #', tokenId.toString())); // NFT title        
        string[7] memory attr = ["The Earth", "Teegarden's Star b", "TOI-700 d", "Kepler-1649 c", "TRAPPIST-1 d", "K2-72e", "Proxima Centauri b"];
        bytes memory image;
        uint256 attrNum;
        (image, attrNum) = _generateSVG(tokenId);
        return string(
            abi.encodePacked('data:application/json;base64,',
            Base64.encode(bytes(abi.encodePacked(
                '{"name":"', name,
                '", "description": "', description,
                '", "image" : "data:image/svg+xml;base64,', Base64.encode(image),
                '", "attributes" : [{"trait_type": "Planet", "value": "', attr[attrNum],
                '"}]}'
            )))
            )
        );
    }

    /**
     * @notice Get default colors for The Earth Property.
     */
   
    function _random(uint256 _input) internal pure returns(uint256){
        return uint256(keccak256(abi.encodePacked(_input)));
    }
}