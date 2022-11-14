// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

//コントラクトはDBに情報を書き込むようなもの
contract EDO2022 is ERC721Enumerable,ERC2981,  Ownable, Pausable {
  //tostringを呼び出すのに必要
    using Strings for uint256;

    string baseURI = "";
    uint256 public preCost = 0.08 ether;
    uint256 public reservedCost = 0.1 ether;
    uint256 public publicCost = 0.1 ether;

    bool public revealed = false;
    bool public presale = false;
    bool public reservedsale = false;
    bool public publicsale = false;
    string public notRevealedUri = "ar://XCVnCenlMwywgG3bAKpClD8tAwupq9zyzoNcdfASYvU";

//定数（constant）は変数（maxsupply）の前に付与
    uint256 constant maxSupply = 2022;
    uint256 constant publicMaxPerTx = 6;
    uint256 constant presaleMaxPerWallet = 2;
    uint256 constant reservedMaxPerWallet = 2;
    string constant baseExtension = ".json";
    bytes32 public presaleMerkleRoot;
    bytes32 public reservedMerkleRoot;

    address public royaltyAddress = 0x6Ce6f6fcbAb24D5b7eE4190eB8F38bA167e0dc48;
    uint96 public royaltyFee = 400;

    mapping(address => uint256) private whiteListClaimed;
    mapping(address => uint256) private reservedListClaimed;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        _setDefaultRoyalty(royaltyAddress, royaltyFee);
    }

    /**
     * @notice Change the royalty fee for the collection
     */
    //  二次流通の利益をだれに渡すかの機能
    function setRoyaltyFee(uint96 _feeNumerator) external onlyOwner {
        royaltyFee = _feeNumerator;
        _setDefaultRoyalty(royaltyAddress, royaltyFee);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981) 
        returns (bool) {
        return super.supportsInterface(interfaceId);
  }

    // internal
    // 絵のURIを参照
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    // public mint
    // パブリックミントの機能
    function publicMint(uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        uint256 cost = publicCost * _mintAmount;
        mintCheck(_mintAmount, supply, cost);
        require(publicsale, "Public mint is paused when public sale is off.");
        require(
            _mintAmount <= publicMaxPerTx,
            "Mint amount cannot exceed 10 per Tx."
        );

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function reservedMint(uint256 _mintAmount, bytes32[] calldata _merkleProof)
        public
        payable
    {
        uint256 supply = totalSupply();
        uint256 cost = reservedCost * _mintAmount;
        mintCheck(_mintAmount, supply, cost);
        require(reservedsale, "ReservedSale is not active.");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, reservedMerkleRoot, leaf),
            "Invalid Merkle Proof"
        );

        require(
            reservedListClaimed[msg.sender] + _mintAmount <= presaleMaxPerWallet,
            "Address already claimed max amount"
        );

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
            reservedListClaimed[msg.sender]++;
        }
    }

    function preMint(uint256 _mintAmount, bytes32[] calldata _merkleProof)
        public
        payable
    {
        uint256 supply = totalSupply();
        uint256 cost = preCost * _mintAmount;
        mintCheck(_mintAmount, supply, cost);
        require(presale, "Presale is not active.");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(
            MerkleProof.verify(_merkleProof, presaleMerkleRoot, leaf),
            "Invalid Merkle Proof"
        );

        require(
            whiteListClaimed[msg.sender] + _mintAmount <= presaleMaxPerWallet,
            "Address already claimed max amount"
        );

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
            whiteListClaimed[msg.sender]++;
        }
    }

    function mintCheck(
        uint256 _mintAmount,
        uint256 supply,
        uint256 cost
    ) private view {
        require(_mintAmount > 0, "Mint amount cannot be zero");
        require(
            supply + _mintAmount <= maxSupply,
            "Total supply cannot exceed maxSupply"
        );
        require(msg.value >= cost, "Not enough funds provided for mint");
    }

    function ownerMint(address _address, uint256 count) public onlyOwner {
        uint256 supply = totalSupply();
        require(
            supply + count <= 2522,
            "Total supply cannot exceed 2522"
        );

        for (uint256 i = 1; i <= count; i++) {
            _safeMint(msg.sender, supply + i);
            safeTransferFrom(msg.sender, _address, supply + i);
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        if (revealed == false) {
            return notRevealedUri;
        }
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function reveal() public onlyOwner {
        revealed = true;
    }

    function setPreSale(bool _state) public onlyOwner {
        presale = _state;
    }

    function setReservedSale(bool _state) public onlyOwner {
        reservedsale = _state;
    }

    function setPublicSale(bool _state) public onlyOwner {
        publicsale = _state;
    }

    function goPublic() public onlyOwner {
        publicsale = true;
        reservedsale = false;
        presale = false;
    }

    function setPreCost(uint256 _cost) public onlyOwner {
        preCost = _cost;
    }

    function setReservedCost(uint256 _cost) public onlyOwner {
        reservedCost = _cost;
    }

    function setPublicCost(uint256 _cost) public onlyOwner {
        publicCost = _cost;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0,'NOTHING_TO_WITHDRAW');
        require(payable(0xC83c9F2893Ce01EF6e57e87DAEbb5A695A81d0FD).send(address(this).balance / 10));
        require(payable(0x6Ce6f6fcbAb24D5b7eE4190eB8F38bA167e0dc48).send(address(this).balance));
    }

    /**
     * @notice Set the merkle root for the allow list mint
     */
    function setPresaleMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        presaleMerkleRoot = _merkleRoot;
    }

    function setReservedMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        reservedMerkleRoot = _merkleRoot;
    }


}