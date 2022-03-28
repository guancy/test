// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract homeworkNFT is ERC721, ERC721URIStorage,Ownable {

    struct classAttribute {

        bool transferable;
        bool burnable;
        bool mintable;
        bool frozen;
        string className;
    }

    uint classCount;
    uint maxClassCount;
    uint256 tokenId;

    //classId=>admin
    mapping(uint => address) public classAdmins;
    //classId=>classAttribute
    mapping(uint=>classAttribute) public  classAttributes;
    //classId=>URI
    mapping(uint=>string) public classURIs;
    //tokenId=>classId
    mapping(uint256=>uint) public tokenIdtoClassId;


    





    constructor() ERC721("homeworkNFT", "hwNFT") {

        classCount = 0;
        maxClassCount =5;
        tokenId=0;
    }


    //regist class with uri and attribute
    function registClass(string memory URI,classAttribute memory attribute) public onlyOwner
    {
        require(classCount <=maxClassCount,"Reached the Max Class Count");

        address register = msg.sender;

        classAdmins[classCount]=register;
        classURIs[classCount] =URI;
        classAttributes[classCount]= attribute;

        classCount=classCount+1;

    }

    //mint by class
    function classMint(address to,uint classId) public
    {
        address _sender = msg.sender;
        require(_sender==classAdmins[classId],"Not Class Admin");
        require(classAttributes[classId].mintable==true,"Not Mintable");

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, classURIs[classId]);

        tokenIdtoClassId[tokenId] = classId;
        tokenId=tokenId+1;

    }

    
    //random mint
    function randomMint(address to ) public
    {
        
        uint randomNounce =0;

        // not real random
        uint random = uint(keccak256(abi.encodePacked(randomNounce,msg.sender,block.timestamp))) % (classCount-1);


        //until revert or mintable
        while(classAttributes[random].mintable==false)
        {
            randomNounce=randomNounce+1;
            random = uint(keccak256(abi.encodePacked(randomNounce,msg.sender,block.timestamp))) % (classCount-1);


        }

        classMint(to,random);

    }
  
    function _burn(uint256 _tokenId) internal override(ERC721, ERC721URIStorage) {

        super._burn(_tokenId);
    }

    //burn
    function burn(uint256 _tokenId) public {
        require(classAttributes[tokenIdtoClassId[_tokenId]].burnable==true,"Not Burnable");
        require(ERC721.ownerOf(_tokenId)==msg.sender,"not owner");
        super._burn(_tokenId);
    }


    function transferFrom(address from, address to, uint256 _tokenId) public virtual override {
        require(classAttributes[tokenIdtoClassId[_tokenId]].transferable==true,"Not Transferable");
        require(ERC721.ownerOf(_tokenId)==msg.sender,"not owner");

        _transfer(from, to, _tokenId);
    }

    //transfer 
    function safeTransferFrom(address from, address to, uint256 _tokenId) public virtual override {
        safeTransferFrom(from, to, _tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 _tokenId, bytes memory _data) public virtual override {
        require(classAttributes[tokenIdtoClassId[_tokenId]].transferable==true,"Not Transferable");
        require(ERC721.ownerOf(_tokenId)==msg.sender,"not owner");
        _safeTransfer(from, to, _tokenId, _data);
    }

 
    //change classAttribute
    function changeClassAttributes(uint classId,classAttribute memory attribute) public
    {
        address _sender = msg.sender;
        require(_sender==classAdmins[classId],"Not Class Admin");
        require(classAttributes[classId].frozen==true,"Been Frozen");

        classAttributes[classId] = attribute;
        
    }


    //change classAdmins
    function changeAdmin(address to,uint classId) public
    {
        address _sender = msg.sender;
        require(_sender==classAdmins[classId],"Not Class Admin");
        classAdmins[classId] = to;

    }


    //return tokenURI
    function tokenURI(uint256 _tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
    {
        return super.tokenURI(_tokenId);
    }

    //return token classname
    function tokenClassName(uint256 _tokenId)
    public
    view
    returns (string memory)
    {
        return classAttributes[tokenIdtoClassId[_tokenId]].className;
    }
    

    //return className
    function className(uint classId)
    public
    view
    returns (string memory)
    {
        return classAttributes[classId].className;
    }


}
