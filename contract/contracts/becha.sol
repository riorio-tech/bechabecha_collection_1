//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "erc721a/contracts/ERC721A.sol";

contract Becha is ERC721A,ERC2981,Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    string public baseURI = "";
    uint256 public almintPrice  = 0.008 ether;
    uint256 public mintPrice = 0.01 ether;
    uint256 public batchSize = 100;
    uint256 public maxPerWallet = 2;
    uint256 public tokenCount;

    uint256 private _totalSupply = 100;

    bool public revealed = false;
    bool public presale = false;
    bool public publicsale = false;

    string private revealUri;
    string constant private metadata = ".json";

    mapping(address => bool) public Allowlist;
    mapping(address => uint256) public Minted;

    constructor() ERC721A("Becha", "BECHA") {
    tokenCount = 0;
    }

    function addAllowlist(address[] calldata _addresses) external onlyOwner{
        for (uint256 i = 0; i < _addresses.length; i++) {
            Allowlist[_addresses[i]] = true;
        }
    }

    function setPresale(bool _state) public onlyOwner {
        presale = _state;
    }

    function setalPrice (uint256 _newPrice ) public onlyOwner {
        almintPrice  = _newPrice ;
    }

    function setPrice(uint256 _newPrice) public onlyOwner {
        mintPrice = _newPrice;
    }

    function setPreMax(uint256 _maxPerWallet) public onlyOwner {
        maxPerWallet = _maxPerWallet;
    }

    // AllowList mint
    function preMint(uint256 quantity) public payable {
        // require(presale, "Presale is not active.");
        // require((quantity + tokenCount) <= (_totalSupply), "Sold out");
        // require(maxPerWallet >= quantity, "AllowlistMint: 2 max per tx");
        // require(msg.value == almintPrice * quantity, "Value sent is not correct");
        Minted[msg.sender] += quantity;
        _safeMint(msg.sender, quantity);
        tokenCount += quantity;
    }

    function publicMint(uint256 quantity) public payable {
        require(!presale, "Public mint is not yet.");
        require((quantity + tokenCount) <= (_totalSupply), "Sold out");
        require(maxPerWallet >= quantity, "publicMint: 2 max per tx");
        require(Allowlist[msg.sender], "No Allowlist");
        Minted[msg.sender] += quantity;
        _safeMint(msg.sender, quantity);
        tokenCount += quantity;
    }

    function ownerMint(uint256 quantity, address to) external onlyOwner {
        require((quantity + tokenCount) <= (_totalSupply), "too many already minted before patner mint");
        _safeMint(to, quantity);
        tokenCount += quantity;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
    );

    string memory baseURI = _baseURI();
    return
        bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString()))
        : "";
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0,'No barance');
        require(payable(0x71787469879aa8c5Fe80ee3b6aAe844D647dAaa0).send(address(this).balance));
    }

    function setHiddenBaseURI(string memory _uri) public onlyOwner {
        revealUri = _uri;
    }

    function setreveal(bool _bool) external onlyOwner {
        revealed = _bool;
    }
}