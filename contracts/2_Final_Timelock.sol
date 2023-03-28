// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract TimeLock{

    //error NotOwner;
event Queue(
        bytes indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );
    event Execute(
        bytes indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );
    event Cancel(bytes indexed txId);

    uint public constant MIN_DELAY = 100; // seconds
    //uint public constant MAX_DELAY = 1000; // seconds
    uint public constant GRACE_PERIOD = 1000; // seconds

    address public owner;

    struct TrunTransaction{
        address target;
        address caller;
        uint value;
        string func;
        address Adminaddress;
        uint timestamp;
        bytes _tx;
    }  
    bytes public txd;
    TrunTransaction[] public Txtransaxtion;
   modifier txExists(uint _txIndex) {
        require(_txIndex < Txtransaxtion.length, "tx does not exist");
        _;
    }
    // tx id => queued
    mapping(bytes => bool) public queued;

    constructor(address Gsafe_address) {
        owner = Gsafe_address;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert("not a Owner");
        }
        _;
    }

    //receive() external payable {}

    function getTxId(
        address _target,
        uint _value,
        string calldata _func,
        address _addadmin,
        uint _timestamp
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_target, _value, _func, _addadmin, _timestamp));
    }


    function queue(
        address _target,
        uint _value,
        string calldata _func,
        address _Adminaddress
        
    ) external onlyOwner returns (bytes memory txId) {
        txId = (abi.encodeWithSignature(_func, _Adminaddress));
         //txId=(abi.encodeWithSignature("testaddadmin(string)", namedasfe));
        if (queued[txId]) {
            revert("it is already in queued");// AlreadyQueuedError(txId);
        }
        // ---|------------|---------------|-------
        //  block    block + min     block + max
        // if (
        //     _timestamp < block.timestamp + MIN_DELAY ||
        //     _timestamp > block.timestamp + MAX_DELAY
        // ) {
        //     revert("Timestamp is not in range");// TimestampNotInRangeError(block.timestamp, _timestamp);
        // }

        queued[txId] = true;
        Txtransaxtion.push(
            TrunTransaction({
            target:_target,
            caller:msg.sender,
            value:_value,
            func:_func, 
            Adminaddress:_Adminaddress,
            timestamp:block.timestamp,
            _tx:txId
            })
        );

        //emit Queue(txId, _target, _value, _func, _data, _timestamp);
    }

    function execute(
        uint id) txExists(id)
        external onlyOwner returns (bytes memory) {
        //bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        TrunTransaction storage transaction = Txtransaxtion[id];
        if (!queued[transaction._tx]) {
            revert("Transaction is not Queued");// NotQueuedError(txId);
        }
        // ----|-------------------|-------
        //  timestamp    timestamp + grace period
        if (block.timestamp < transaction.timestamp) {
            revert("Time stamp is not passed ");// TimestampNotPassedError(block.timestamp, _timestamp);
        }
        if (block.timestamp > transaction.timestamp + GRACE_PERIOD) {
            revert("Time stamp Expired"); // TimestampExpiredError(block.timestamp, _timestamp + GRACE_PERIOD);
        }

        queued[transaction._tx] = false;

        (bool ok, bytes memory res) = transaction.target.call{value: transaction.value}(
            abi.encodeWithSignature(transaction.func, transaction.Adminaddress)
        );
        if (!ok) {
            revert("Transaction is failed"); //TxFailedError();
        }

        //emit Execute(txId, target, value, func, data, timestamp);

        return res;
    }

    function cancel(uint id)  external onlyOwner txExists(id){
       TrunTransaction storage transaction = Txtransaxtion[id];
       if (!queued[transaction._tx]) {
            revert("Transaction is not Queued");// NotQueuedError(txId);
        }

        queued[transaction._tx] = false;

        emit Cancel(transaction._tx);
    }


}








contract TimelockTest{
    address public timelock;
    
address public Mohan;
string public Kumar;
    constructor(address _timelock){

        timelock=_timelock;
    }
    function testaddadmin(address adminname)   external {
        require(msg.sender==timelock,"the caller is not a timelock");
            Mohan=adminname; 
            Kumar="Finally we have done this";
       // transaction;
       // add;

    }
    function test1()  external {
        require(msg.sender==timelock,"the caller is not a timelock");
            Kumar="Hello"; 
       // transaction;
       // add;

    }
    

    function gettimes() public view returns(uint) {
        return block.timestamp+100;
    }
}




// pragma solidity ^0.8.0;

// contract Receiver {
//     event Received(address caller, uint amount, string message);

//     fallback() external payable {
//         emit Received(msg.sender, msg.value, "Fallback was called");
//     }

//     function foo(string memory _message, uint _x) public payable returns (uint) {
//         emit Received(msg.sender, msg.value, _message);

//         return _x + 1;
//     }
// }

// contract Caller {
//     event Response(bool success, bytes data);

//     // Let's imagine that contract B does not have the source code for
//     // contract A, but we do know the address of A and the function to call.
//     function testCallFoo(address payable _addr) public payable {
//         // You can send ether and specify a custom gas amount
//         (bool success, bytes memory data) = _addr.call{value: msg.value, gas: 5000}(
//             abi.encodeWithSignature("foo(string,uint256)", "call foo", 123)
//         );

//         emit Response(success, data);
//     }

//     // Calling a function that does not exist triggers the fallback function.
//     function testCallDoesNotExist(address _addr) public {
//         (bool success, bytes memory data) = _addr.call(
//             abi.encodeWithSignature("doesNotExist()")
//         );

//         emit Response(success, data);
//     }
// }
