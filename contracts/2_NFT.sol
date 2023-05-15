// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MyToken is ERC721, Ownable {
    constructor() ERC721("MOhanG", "MG") {}
    using SafeMath for uint;
 struct NFTOnwers{
     address seller;
     uint price;
 }
 uint public remaining;
 address public mohanaddress;
 mapping (uint => NFTOnwers[]) public buyers;
 
    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
       // buyers[tokenId].push(NFTOnwers(msg.sender,price));
    }

    function ListNFT(uint tokenid,uint price) public {
        require(price > 0, "NFTMarket: price should be not suffient");
        transferFrom(msg.sender, address(this), tokenid);
        buyers[tokenid].push(NFTOnwers(msg.sender,price));
        mohanaddress=buyers[tokenid][buyers[tokenid].length-1].seller;
    }

    function buyNFT(uint tokenid) public payable {
       uint len= buyers[tokenid].length;
       require(len>0,"array should not be less");
       require(buyers[tokenid][len-1].price >0 , "NFTMarket: token does not exist");
       require(msg.value >= buyers[tokenid][len-1].price, "price is less");
      
       
        uint ethPrice= uint(msg.value);
        uint eth= ethPrice.mul(96).div(100);
 
         uint balance = eth.mul(4).div(100);
          remaining = balance.div(len);
         (bool success,)= (buyers[tokenid][len-1].seller).call{value : eth}("");
         require(success,"its not success");
         uint total =0;
            
        //);
        for (uint i = 0;i<len;i++){
            total = total+remaining;
            (bool suc,)= (buyers[tokenid][i].seller).call{value:remaining}("");
            require(suc,"inside");
        }
        
       ERC721(address(this)).transferFrom(address(this), msg.sender, tokenid);
    }

    function withdraw() public  {
        uint amount = address(this).balance;
        (bool ss,)=payable(msg.sender).call{value:amount}("");
        require(ss,"its failed");
    }
    function getBalance() public  view returns(uint)   {
        return address(this).balance;
    }


    
}