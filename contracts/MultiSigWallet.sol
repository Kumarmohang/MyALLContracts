// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract MultiSigWalletOwner is MultiSigWallet{
    event _Deposit(address indexed sender, uint amount, uint balance);
    event _SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event _ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event _RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event _ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public _numConfirmationsRequired;

    struct _Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    // mapping from tx index => owner => bool
    mapping(uint => mapping(address => bool)) public _isConfirmed;

    _Transaction[] public _transactions;

    // modifier onlyOwner() {
    //     require(isOwner[msg.sender], "not owner");
    //     _;
    // }

    modifier _txExists(uint _txIndex) {
        require(_txIndex < _transactions.length, "tx does not exist");
        _;
    }

    modifier _notExecuted(uint _txIndex) {
        require(!_transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier _notConfirmed(uint _txIndex) {
        require(!_isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint _numConfirmationsrequired) {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsrequired > 0 &&
                _numConfirmationsrequired <= _owners.length,
            "invalid number of required confirmations"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        _numConfirmationsRequired = _numConfirmationsrequired;
    }

    // receive() external payable {
    //     emit _Deposit(msg.sender, msg.value, address(this).balance);
    // }

    function _submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner {
        uint txIndex = _transactions.length;

        _transactions.push(
            _Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0
            })
        );

        emit _SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function _confirmTransaction(uint _txIndex)
        public
        onlyOwner
        _txExists(_txIndex)
        _notExecuted(_txIndex)
        _notConfirmed(_txIndex)
    {
        _Transaction storage _transaction = _transactions[_txIndex];
        _transaction.numConfirmations += 1;
        _isConfirmed[_txIndex][msg.sender] = true;

        emit _ConfirmTransaction(msg.sender, _txIndex);
    }

    function _executeTransaction(uint _txIndex)
        public
        onlyOwner
        _txExists(_txIndex)
        _notExecuted(_txIndex)
    {
        _Transaction storage _transaction = _transactions[_txIndex];

        require(
            _transaction.numConfirmations >= _numConfirmationsRequired,
            "cannot execute tx"
        );

        _transaction.executed = true;

        (bool success, ) = _transaction.to.call{value: _transaction.value}(
            _transaction.data
        );
        require(success, "tx failed");

        emit _ExecuteTransaction(msg.sender, _txIndex);
    }

    function _revokeConfirmation(uint _txIndex)
        public
        onlyOwner
        _txExists(_txIndex)
        _notExecuted(_txIndex)
    {
        _Transaction storage _transaction = _transactions[_txIndex];

        require(_isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        _transaction.numConfirmations -= 1;
        _isConfirmed[_txIndex][msg.sender] = false;

        emit _RevokeConfirmation(msg.sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function g_etTransactionCount() public view returns (uint) {
        return _transactions.length;
    }

    function _getTransaction(uint _txIndex)
        public
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        _Transaction storage _transaction = _transactions[_txIndex];

        return (
            _transaction.to,
            _transaction.value,
            _transaction.data,
            _transaction.executed,
            _transaction.numConfirmations
        );
    }
}