// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";



/** @author Omnes Blockchain team www.omnestech.org (@Afonsodalvi, @G-Deps @EWCunha and @renancorreadev)
    @title ERC721A contract for smart contract course for law professionals
    ipfs: https://bafybeid7rsqvtd454ra4tkfa3y2vobmz75zexgxe6zndsj5jk23tbjdnsq.ipfs.nftstorage.link/
    */
contract IDsubmit is ERC721A, Pausable, Ownable {

    //erros
    error NonExistentTokenURI();
    error WithdrawTransfer();
    error MentoringNotApproved();
    error MintPriceNotPaid();

    /** @dev event Soulbound
        @param to: address to 
        @param tokenId: id soulbound */
    event Attest(address indexed to, uint256 indexed tokenId);
    event Revoke(address indexed to, uint256 indexed tokenId);

    
    string public baseURI;
    mapping(uint256 => string) public idURIs;

    // SFTRec settings -- omnesprotocol
    uint256 public price;  // full price per hour
    uint256 public maxDiscount;

    // Mentoring setting
    uint public priceSign; // payment sign

    constructor(string memory baseuri, uint256 _price, 
    uint256 _priceSign, string memory _nome, string memory _symbol)
    ERC721A(_nome, _symbol) {
       baseURI = baseuri;
       priceSign = _priceSign;
       price = _price;
       
    }

    function mint() external payable whenNotPaused {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`
         if (msg.value >= price-((price*maxDiscount)/10000)) {
            revert MintPriceNotPaid();
        }
        _mint(msg.sender, 1);

    }


    function Airdrop(address _to) external payable onlyOwner{
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(_to, 1);
    }

    //set functions

    function setURI(string memory newUri)external onlyOwner{
        baseURI = newUri;
    }

    function setTokenIdURI(string memory _idURI, uint256 _id) external onlyOwner{
        if (!_exists(_id)) revert URIQueryForNonexistentToken();
        string memory newidURI = _idURI; // insert / after IPFS link CID to work properly
        idURIs[_id] = newidURI;
    }

    function setPrice(uint256 _priceperHour, uint256 _priceSign) external onlyOwner{
        price = _priceperHour;
        priceSign = _priceSign;
    }

    function setMaxdiscont(uint256 _maxDiscont)external onlyOwner{
        maxDiscount = _maxDiscont;
    }

    // Souldbound token delimitations
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal override(ERC721A){
        require(from == address(0) || to == address(0), 
        "Not allowed to transfer token");
    }

    function _afterTokenTransfers(address from,
        address to,
        uint256 startTokenId,
        uint256 quantity) override internal {
        if (from == address(0)) {
            emit Attest(to, startTokenId);
        } else if (to == address(0)) {
            emit Revoke(to, startTokenId);
        }
    }

    function revoke(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }

    // returns functions
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseuRI = _baseURI();
        string memory json = ".json";
        if (!compareStrings(idURIs[tokenId],baseuRI)) {
        return bytes(idURIs[tokenId]).length != 0 ? string(abi.encodePacked(idURIs[tokenId], _toString(tokenId), json)) : '';
        } else { 
        return bytes(baseuRI).length != 0 ? string(abi.encodePacked(baseuRI, _toString(tokenId), json)) : '';
        }
    }

    function pause() public onlyOwner{
        _pause();
    }

    function unpause() public onlyOwner{
        _unpause();
    }

    //returns
    function _baseURI() internal view override returns (string memory){
        return baseURI;
    }

    //Helpers functions
    function compareStrings(string memory a, string memory b) internal pure returns(bool){
        return (keccak256(abi.encodePacked(a)) ==  keccak256(abi.encodePacked(b)));
    }

     //withdraw Functions
    function withdrawPayments(address payable payee) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool transferTx, ) = payee.call{value: balance}("");
        if (!transferTx) {
            revert WithdrawTransfer();
        }
    }

}