// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "erc721a/contracts/IERC721A.sol";

import {Ibuilder} from "./interfaces/Ibuilder.sol";



/** @author Omnes Blockchain team www.omnestech.org (@Afonsodalvi, @G-Deps)
    @title ERC721A contract for smart contract ETHEREUM SP
    ipfs: https://bafybeid7rsqvtd454ra4tkfa3y2vobmz75zexgxe6zndsj5jk23tbjdnsq.ipfs.nftstorage.link/
    */
contract IDbuilder is ERC721A, Pausable, Ownable, Ibuilder {

    //erros
    error NonExistentTokenURI();
    error WithdrawTransfer();
    error MintPriceNotPaid();

    /** @dev event Soulbound
        @param to: address to 
        @param tokenId: id soulbound */
    event Attest(address indexed to, uint256 indexed tokenId);
    event Revoke(address indexed to, uint256 indexed tokenId);

    string[] private _scriptURI; //when use A.I 
    
    string public baseURI;
    string public generalURI = "https://bafybeieifvwsa7qcphtagbqg4wwaqcdhhdcw2umi5qnbuvajqbsduj6ggi.ipfs.nftstorage.link/Aluno.json";
    mapping(uint256 => string) public idURIs;
    mapping(address => dados) private dadosID;


    // SFTRec settings -- omnesprotocol
    uint256 public price;  // full price per hour
    uint256 public maxDiscount;


    constructor( )
    ERC721A("IDentity builder", "IDBUILDER") {
       baseURI = generalURI;
    }

    function mintBuilder(string memory _email, bool _student, bool _teacher) external payable whenNotPaused returns(uint256){
        
        dadosID[msg.sender] = dados(_email, _student, _teacher);
        _mint(msg.sender, 1);
        return _nextTokenId() -1;

    }


    function Airdrop(address _to) external payable onlyOwner returns(uint256){
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(_to, 1);
        return _nextTokenId() -1;
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

    function setPrice(uint256 _price) external onlyOwner{
        price = _price;
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
    }

    function _afterTokenTransfers(address from,
        address to,
        uint256 startTokenId,
        uint256 quantity) override internal {
        
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
        return bytes(baseuRI).length != 0 ? string(abi.encodePacked(baseuRI, _toString(tokenId))) : generalURI;
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


    //ERC5169 

    function scriptURI() external view override returns(string[] memory) {
        return _scriptURI;
    }

    function setScriptURI(string[] memory newScriptURI) external onlyOwner override {
        _scriptURI = newScriptURI;

        emit ScriptUpdate(newScriptURI);
    }

}