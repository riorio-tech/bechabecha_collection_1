// SPDX-License-Identifier: MIT
/*
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@           @@              @@         @@                     @@      @@@@@@@@@@
@@@@@@@@@@@@@@@            @@              @@          @@                    @@      @@@@@@@@@@
@@@@@@@@@@@@@@             @@     @@@@@@@@@@@           @@     @@@@@@@@@@@@@@@@      @@@@@@@@@@
@@@@@@@@@@@@@      @       @@     @@@@@@@@@@@       @    @@     @@@@@@@@@@@@@@@      @@@@@@@@@@
@@@@@@@@@@@@      @@       @@     @@@@@@@@@@@       @@    @@     @           @@      @@@@@@@@@@
@@@@@@@@@@@      @@@       @@              @@       @@@    @@     @          @@      @@@@@@@@@@
@@@@@@@@@@     @           @@              @@          @    @@     @@@@@@    @@      @@@@@@@@@@
@@@@@@@@@     @            @@@@@@@@@@@     @@           @    @@     @@@@@    @@      @@@@@@@@@@
@@@@@@@@     @@@@@@@       @@@@@@@@@@@     @@       @@@@@@    @@     @@@@    @@      @@@@@@@@@@
@@@@@@@     @@@@@@@@       @@@@@@@@@@@     @@       @@@@@@@    @@     @@@    @@      @@@@@@@@@@
@@@@@@     @@@@@@@@@       @@              @@       @@@@@@@@    @@           @@      @@@@@@@@@@
@@@@@     @@@@@@@@@@       @@              @@       @@@@@@@@@    @@          @@      @@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "./ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Asagi is Ownable, ERC721A, ReentrancyGuard, ERC2981{
    uint256 public tokenCount;
    uint256 public batchSize = 100;
    uint256 private wLMintPrice = 0.03 ether;
    uint256 private mintPrice = 0.05 ether;
    uint256 public MintLimit = 3;
    uint256 public _totalSupply = 1500;
    bool public wlSaleStart = false;
    bool public saleStart = false;
    mapping(address => uint256) public Minted; 
    bytes32 public merkleRoot;

    address public royaltyAddress;
    uint96 public royaltyFee = 1000;
    bool public revealed = false;
    
  constructor(
  ) ERC721A("Asagi", "ASAGI",batchSize, _totalSupply) {
     tokenCount = 0;
  }
  // ホワイトリスト持っている人がミントできる
  function wlMint(uint256 quantity, bytes32[] calldata _merkleProof) public payable nonReentrant {
    bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

    require(MintLimit >= quantity, "limit over");
    require(MintLimit >= Minted[msg.sender] + quantity, "You have no Mint left");
    require(msg.value == wLMintPrice * quantity, "Value sent is not correct");
    require((quantity + tokenCount) <= (_totalSupply), "Sorry. No more NFTs");
    require(wlSaleStart, "Sale Paused");    
    require(MerkleProof.verify(_merkleProof, merkleRoot, leaf),"Invalid Merkle Proof");
         
    Minted[msg.sender] += quantity;
    _safeMint(msg.sender, quantity);
    tokenCount += quantity;
  }

}



  function psMint(uint256 quantity) public payable nonReentrant {
    require(MintLimit >= quantity, "limit over");
    require(MintLimit >= Minted[msg.sender] + quantity, "You have no Mint left");
    require(msg.value == mintPrice * quantity, "Value sent is not correct");
    require((quantity + tokenCount) <= (_totalSupply), "Sorry. No more NFTs");
    require(saleStart, "Sale Paused");
         
    Minted[msg.sender] += quantity;
    _safeMint(msg.sender, quantity);
    tokenCount += quantity;
  }


  function switchWlSale(bool _state) external onlyOwner {
    wlSaleStart = _state;
  }
  function switchSale(bool _state) external onlyOwner {
    saleStart = _state;
  }
  function setWlLimit(uint256 newLimit) external onlyOwner {
    MintLimit = newLimit;
  }
  function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
    merkleRoot = _merkleRoot;
  }
// ミントした人のトークンIDをランダムで付与
  function walletOfOwner(address _address) public view returns (uint256[] memory) {
    uint256 ownerTokenCount = balanceOf(_address);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
      for (uint256 i; i < ownerTokenCount; i++) {
        tokenIds[i] = tokenOfOwnerByIndex(_address, i);
      }
    return tokenIds;
  }

  //set Default Royalty._feeNumerator 500 = 5% Royalty
  function setRoyaltyFee(uint96 _feeNumerator) external onlyOwner {
    royaltyFee = _feeNumerator;
    _setDefaultRoyalty(royaltyAddress, royaltyFee);
  }

  //Change the royalty address where royalty payouts are sent
  function setRoyaltyAddress(address _royaltyAddress) external onlyOwner {
    royaltyAddress = _royaltyAddress;
    _setDefaultRoyalty(royaltyAddress, royaltyFee);
  }
  
  //Implementation on wear change from here down.
  //URI
  string public _baseTokenURI;
  string private revealUri;

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    require(_exists(_tokenId), "URI query for nonexistent token");
    if(revealed == false) {
      return revealUri;
      }
    return string(abi.encodePacked(_baseURI(_tokenId), Strings.toString(_tokenId), ".json"));
  }

  //set URI
  function setBaseURI(string calldata baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }
  function setHiddenBaseURI(string memory uri_) public onlyOwner {
    revealUri = uri_;
  }
  function setreveal(bool bool_) external onlyOwner {
    revealed = bool_;
  }
  }

}