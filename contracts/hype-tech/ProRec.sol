// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/IERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
//import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {IProRec} from "./interfaces/IProRec.sol";



/** @author Omnes Blockchain team www.omnestech.org (@Afonsodalvi, @G-Deps)
    @title ERC721A contract for smart contract ETHEREUM SP
    ipfs: https://bafybeid7rsqvtd454ra4tkfa3y2vobmz75zexgxe6zndsj5jk23tbjdnsq.ipfs.nftstorage.link/
    */
contract ProRec is ERC721A, Pausable, Ownable, IProRec {

    //erros
    error NonExistentTokenURI();
    error WithdrawTransfer();
    error MintPriceNotPaid();

    /** @dev event Soulbound
        @param to: address to 
        @param tokenId: id soulbound */
    event Attest(address indexed to, uint256 indexed tokenId);
    event Revoke(address indexed to, uint256 indexed tokenId);

    
    string public baseURI;
    address immutable OwnerHYPETECH;
    mapping(uint256 => string) public idURIs;

    //informações dos alunos, professores e desenvolvedores
    mapping(address => builder) public infobuilder;

    //contabilização de builders -- >= 50%
    uint Totalbuilders;
    //total de entregas
    uint Totaldeliverys;

    //Informações de quem submete projeto
    mapping(address => submit) public infoSubmit;
    //contabilização das submissões
    

    //Informações de quem submete financia os projetos
    mapping(address => funder) public infoFunder;
    //contabilização das submissões
    

    ///@dev Mapping da IProRec See {struct ICRPStaking.StakingCondition}
    mapping(uint256 => Project) private infoProject;
    //total projects
    uint TotalProjects;

    // SFTRec settings -- omnesprotocol
    uint256 public price;  // preço para submeter um projeto
    uint256 public maxDiscount;

    IERC721A public idsubmit;
    IERC721A public idfunder;
    IERC721A public idbuilder;

    // preço para investir no projeto somente por funders
    uint public priceFunder; // payment sign

    constructor(string memory baseuri, uint256 _price, 
    uint256 _priceFunder, string memory _nome, string memory _symbol, 
    address _OwnerHYPETECH, address IDsubmit, address IDfunder, address IDbuilder )
    ERC721A(_nome, _symbol) {
       baseURI = baseuri;
       priceFunder = _priceFunder;
       price = _price;
       OwnerHYPETECH = _OwnerHYPETECH;
       //interface de todos as identidades
       idsubmit = IERC721A(IDsubmit);
       idfunder = IERC721A(IDfunder);
       idbuilder = IERC721A(IDbuilder);
       
    }

    function mintNewProject(uint _id) external payable onlySubmit(_id) {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`
         if (msg.value >= price-((price*maxDiscount)/10000)) {
            revert MintPriceNotPaid(); //implementação do Omnes protocolo aqui e ganhamos por recomendar a levarem novas propostas
        }
        infoProject[_id].idproject;

        unchecked {
            ++TotalProjects;
        }
        _mint(msg.sender, 1);

    }


    function Airdrop(address _to) external payable onlyOwner{
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(_to, 1);
    }

    //only builder -- IProcRec referencia

    
    function deliveryReward(uint _IDentidade, uint value) payable external onlyBuilder(_IDentidade){

        ++infoProject[msg.value].totalvalue;
        
       // payable(msg.sender).transfer();
    }

    
    function deliverystage(uint _IDentidade,address _from, uint _delivery) external onlyBuilder(_IDentidade){

    }


    //set functions geral pela hype-tech

    function setURI(string memory newUri)external onlyOwner{
        baseURI = newUri;
    }

    function setTokenIdURI(string memory _idURI, uint256 _id) external onlyOwner{
        if (!_exists(_id)) revert URIQueryForNonexistentToken();
        string memory newidURI = _idURI; // insert / after IPFS link CID to work properly
        idURIs[_id] = newidURI;
    }

    function setPrice(uint256 _priceperHour, uint256 _priceFunder) external onlyOwner{
        price = _priceperHour;
        priceFunder = _priceFunder;
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
        } //inserir em uma pasta com imagens diferentes para simular projetos e 
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
    function withdrawPayments(address payable payee) external onlyHypeOwner {
        uint256 balance = address(this).balance;
        (bool transferTx, ) = payee.call{value: balance}("");
        if (!transferTx) {
            revert WithdrawTransfer();
        }
    }




    //modifiers 

    modifier onlyHypeOwner{
        require(msg.sender == OwnerHYPETECH, "Only Hyper Owner");
        _;
    }

    modifier onlyBuilder(uint _id){
        require(msg.sender == idbuilder.ownerOf(_id), "Only Builder");
        _;
    }

    modifier onlyFunder(uint _id){
        require(msg.sender == idfunder.ownerOf(_id), "Only funder");
        _;
    }

    modifier onlySubmit(uint _id){
        require(msg.sender == idsubmit.ownerOf(_id), "Only submit");
        _;
    }

    

}