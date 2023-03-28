// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

  struct NFTListing {
        uint256 price;
        address seller;
    }
 

contract NFTMarket is ERC721URIStorage,Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    using SafeMath for uint256;
    address public _owner;
    
    event NFTTransfer(uint256 tokenid,address to ,string tokenuri,uint256 Price);

    mapping(uint256 => NFTListing) private _listings;

    constructor() ERC721("MohanG", "MG") {  }

    function createNFT(string memory tokenURI)
        public
        returns (uint256)
    {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
    }

    // List NFT 

    function listNFT(uint tokenID,uint Price) public {

        require(Price > 0 ,"NFTMarket: price must be greater than 0");
        transferFrom(msg.sender, address(this), tokenID);
        _listings[tokenID]= NFTListing(Price,msg.sender);
        emit NFTTransfer( tokenID, address(this),"",Price);

    }

    // buyNFT
    function buyNFT(uint tokenId) public payable {
        NFTListing memory listing= _listings[tokenId];
        require(listing.price >0 , "NFTMarket: nft is not listed for sale");
        require(msg.value == listing.price, "NFTMarket: incorrect price");
        transferFrom(address(this), msg.sender, tokenId);
        payable(msg.sender).transfer(listing.price.mul(95).div(100));
        emit NFTTransfer(tokenId, msg.sender, "", listing.price);
    }

    //cancel Listing

    function cancelListing(uint256 tokenID) public payable{
        NFTListing memory listing = _listings[tokenID];
        require(listing.price >0 , "NFTMarket: nft is not listed for sale");
        require(listing.seller==msg.sender,"NFTMarket: you're not the owner");
        transferFrom(address(this), msg.sender, tokenID);
         emit NFTTransfer(tokenID, msg.sender, "", 0);
        clearListing(tokenID);

    }

    function clearListing(uint256 tokenID) internal {
         _listings[tokenID].price=0;
         _listings[tokenID].seller=address(0);
    } 

    function withDrawFunds() public onlyOwner {
        uint256 balance= address(this).balance;
        require(balance> 0 ,"NFTMarket: balace is zero");
        payable(msg.sender).transfer(balance);
    }

}