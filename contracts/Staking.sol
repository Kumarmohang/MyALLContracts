//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Staking  {
    mapping(address => uint256) private _stakedBalances;
    

    address private tokenAddress;

    uint256 totalStakedBalance;
     bool internal locked;
    event StakeChanged(address staker, uint256 newStakedBalance);
    event Withdraw(address stakeAddress,address toAddress,uint value);

    constructor(address _token) {
        tokenAddress = _token;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    /**
     * @dev returns address of the token that can be staked
     *
     * @return the address of the token contract
     */
    function getTokenAddress() public view returns (address) {
        return tokenAddress;
    }


    /**
     * @dev Gets staker's staked balance (voting power)
     * @param staker                 The staker's address
     * @return (uint) staked token balance
     */
    function balanceOf(address staker) external view  returns(uint256) {
        return _stakedBalances[staker];
    }

    /**
     * @dev allows a user to stake and to increase their stake
     * @param amount the uint256 amount of native token being staked/added
     * @notice user must first approve staking contract for at least the amount
     */
    function stake(uint256 amount) external noReentrant  {
        IERC20 tokenContract = IERC20(tokenAddress);
        require(tokenContract.balanceOf(msg.sender) >= amount, "Amount higher than user's balance");
        require(tokenContract.allowance(msg.sender, address(this)) >= amount, 'Approved allowance too low');
        require(
            tokenContract.transferFrom(msg.sender, address(this), amount),
            "staking tokens failed"
        );
        totalStakedBalance += amount;
        _stakedBalances[msg.sender] += amount;

        emit StakeChanged(msg.sender, _stakedBalances[msg.sender]);
    }

    /**
     * @dev allows a user to withdraw their unlocked tokens
     * @param amount the uint256 amount of native token being withdrawn
     */
    function withdraw(uint256 amount) external noReentrant {
       
        require(
            _stakedBalances[msg.sender] >= amount,
            "Insufficient staked balance"
        );
        require(totalStakedBalance >= amount, "insufficient funds in contract");

        // Send unlocked tokens back to user
        totalStakedBalance -= amount;
        _stakedBalances[msg.sender] -= amount;
        IERC20 tokenContract = IERC20(tokenAddress);
        require(tokenContract.transfer(msg.sender, amount), "withdraw failed");
        emit  Withdraw(tokenAddress,msg.sender,amount);
    }
 
}