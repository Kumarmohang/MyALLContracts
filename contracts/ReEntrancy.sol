// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract bank{

    mapping(address => uint) public balance;
    address public owner;

    constructor() {
        owner=msg.sender ;
    }

    function deposite() public payable {
        require(msg.value >= 1 ether, "expecting more ethers");
        balance[address(this)]  = balance[address(this)] + msg.value;

    }

    function withdraw (uint val) public {
       // require(msg.sender== owner, "caller must be owner");
        uint bal= balance[address(this)];
        require(bal>=val , "No balance ");
        (bool success,)=msg.sender.call{value: val}("");
        require(success,"tx is failed");
        balance[address(this)]=balance[address(this)]-val;
    }
}