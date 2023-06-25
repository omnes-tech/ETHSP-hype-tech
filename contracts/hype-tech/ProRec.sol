// SPDX-License-Identifier: MIT 
pragma solidity >=0.8.15;

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/IERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


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
    // uint Totalbuilders;
    //total de entregas
    // uint Totaldeliverys;

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

    function submitNewProject(uint _quantity, uint _totalValue) payable external onlySubmit() {
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`
         if (msg.value < price-((price*maxDiscount)/10000)) {
            revert MintPriceNotPaid(); //implementação do Omnes protocolo aqui e ganhamos por recomendar a levarem novas propostas
        }

        address[] memory taker;

        infoProject[++TotalProjects] = Project({
            quantity: _quantity,
            totalvalue : _totalValue,
            takers : taker,
            pause : true,
            idproject : _nextTokenId(),
            delivered : false
        });


        ERC721A._mint(msg.sender, 1);

    }

    function fundProject(uint _projectId) external payable onlyFunder returns (bool){
        Project memory _aux = infoProject[_projectId];
        require(_aux.totalvalue <= _aux.totalvalue + msg.value,"ProRec : Amount to fund is over the project limit");
        infoProject[_projectId].totalvalue = _aux.totalvalue + msg.value;

        infoFunder[msg.sender].value += msg.value;

        return true;
    }

    function getProject(uint _projectId) external onlyBuilder {
        Project memory _aux = infoProject[_projectId];
        require(_aux.takers.length+1 <= _aux.quantity, "ProRec : Not more takers allowed");
        require(infobuilder[msg.sender].projectId == 0, "ProRec : Already in a project");
        infoProject[_projectId].takers.push(msg.sender);
        infobuilder[msg.sender].projectId = _projectId;
    }

    function deliverBuilder(uint _projectId, string memory _link) external onlyBuilder {
        builder memory _aux = infobuilder[msg.sender];
        Project memory _project = infoProject[_projectId];
        require(_aux.projectId == _projectId,"ProRec : Wrong project");
        require(_aux.delivery < 3, "ProRec : Already Delivered");
        require(compareStrings(_aux.link, link) == false, "ProRec : Already Delivered" );

        infobuilder[msg.sender].delivery++;
        infobuilder[msg.sender].link;

        uint _internalCounter;

        for(uint i=0; i<_project.quantity; i++){
            if(infobuilder[_project.takers[i]].delivery == 3)
            _internalCounter++;
        }

        if(_internalCounter == _project.quantity)
        infoProject[_projectId].delivered = true;

    }

    function claimCompensation(uint _projectId) external onlyBuilder {
        Project memory _aux = infoProject[_projectId];
        require(_aux.delivered, "ProRec : Not fully delivered yet");
        require(infobuilder[msg.sender].projectId == _projectId, "ProRec : Wrong Project");

        infobuilder[msg.sender].reputation++;
        infobuilder[msg.sender].projectId = 0;

        (bool success, ) = payable(msg.sender).call{value:_aux.totalvalue/_aux.quantity}("");
        require(success, "ProRec : Payment not completed");
    }


    function Airdrop(address _to) external payable onlyOwner{
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
        _mint(_to, 1);
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
        return bytes(idURIs[tokenId]).length != 0 ?
            string(abi.encodePacked(idURIs[tokenId], _toString(tokenId), json)) : "";
        } else { 
        return bytes(baseuRI).length != 0 ? string(abi.encodePacked(baseuRI, _toString(tokenId), json)) : "";
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

    modifier onlyBuilder(){
        require(!infobuilder[msg.sender].banned && idbuilder.balanceOf(msg.sender) == 1, "Only Builder");
        _;
    }

    modifier onlyFunder(){
        require(idfunder.balanceOf(msg.sender) == 1 && !infoFunder[msg.sender].banned, "Only funder");
        _;
    }

    modifier onlySubmit(){
        require(idsubmit.balanceOf(msg.sender) == 1, "Only submit");
        _;
    }

    

}