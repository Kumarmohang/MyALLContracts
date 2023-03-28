// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Bank {

    address owner;
    bytes32[] public whitelistedSymbols;
    mapping (bytes32 => address) public whitelistedTokens;
    mapping (address => mapping(bytes32 => uint256)) public balances;

    constructor() {
        owner = msg.sender;

    }

    function whitelisToken(bytes32 symbol, address tokenAddress) external {
        require(owner==msg.sender, "only Owner can add a symbol");
        whitelistedSymbols.push(symbol);
        whitelistedTokens[symbol]=tokenAddress;

    }
    function getWhitelistedSymbols() external view returns(bytes32[] memory){
        return whitelistedSymbols;
    }

    function getWhitelistedTokkenAddress(bytes32 symbol) external view returns(address){
        return whitelistedTokens[symbol];
    }
    receive() external payable{
        balances[msg.sender]['Eth'] += msg.value;
    }
    function withdrawEther(uint amount) external payable{
        require(balances[msg.sender]['Eth'] >= amount , "Insufficient funds");
        balances[msg.sender]['Eth'] -= amount;
        payable(msg.sender).call{value:amount}("");

    }
    function depositeTokens(uint256 amount,bytes32 symbol) external{
        balances[msg.sender][symbol] += amount;
        IERC20(whitelistedTokens[symbol]).transferFrom(msg.sender,address(this),amount);
    }

    function withdrwaTokens(uint256 amount, bytes32 symbol) external {
        require(balances[msg.sender][symbol] >= amount);
        balances[msg.sender][symbol] -=amount;
        IERC20(whitelistedTokens[symbol]).transfer(msg.sender,amount);
    }
    function getTokenBalance(bytes32 symbol) public view returns(uint256){
        return balances[msg.sender][symbol];
    }
}