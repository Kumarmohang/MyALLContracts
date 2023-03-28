// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';



// interface IERC20 {
//     function balanceOf(address account) external view returns (uint256);
//     function transfer(address to, uint256 amount) external returns (bool);
//     function approve(address spender, uint256 amount) external returns (bool);
// }

contract SingleSwap is ReentrancyGuard {

    event BatchTransfer(
    address fromAddress,
    address[] indexed toAddress,
    uint[] recipientAmount
  );
  event BatchTransferMultiToken(
    address indexed fromAddress,
    address[] indexed tokenAddress,
    address[] indexed toAddress,
    uint[] recipientAmount
  );
  event BatchTransferToken(
    address indexed fromAddress,
    address indexed tokenAddress,
    address[] indexed toAddress,
    uint[] recipientAmount
  );
  event SimpleBatchTransferToken(
    address indexed fromAddress,
    address indexed tokenAddress,
    address[] indexed toAddress,
    uint[] recipientAmount
  );
  event BatchTransferCombinedMultiTokens(
    address indexed fromAddress,
    address[] indexed tokenAddress,
    address[] tokenRecipientAddress,
    uint[] tokenAmount,
    address[] indexed recipients,
    uint[] amount
  );

    address public constant routerAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    ISwapRouter public immutable swapRouter = ISwapRouter(routerAddress);

    address public constant LINK = 0xeCD0E7659e96C90015B5d4BcC61bFa2Bc858C877;
    address public constant WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    
    IERC20 linkToken = IERC20(LINK);

    uint24 public constant poolFee = 3000;

    constructor() {}
    
    // function getReservers() public view ()

    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {

        linkToken.approve(address(swapRouter), amountIn);


        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: LINK,
                tokenOut: WETH,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        // 100000000000
        amountOut = swapRouter.exactInputSingle(params);
    }

    function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {

        linkToken.approve(address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params =
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: LINK,
                tokenOut: WETH,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        amountIn = swapRouter.exactOutputSingle(params);

        if (amountIn < amountInMaximum) {
            linkToken.approve(address(swapRouter), 0);
            linkToken.transfer(address(this), amountInMaximum - amountIn);
        }
    }

    function addres() public view returns(address){
      return address(0x1);
    }

  function batchTransfer(
    address[] calldata recipients,
    uint256[] calldata amounts
  ) external payable nonReentrant {
    uint totalEthers;
    require(
      recipients.length == amounts.length,
      "The input array must have the same length"
    );
    for (uint i = 0; i < recipients.length; i++) {
      require(recipients[i] != address(0), "Recipient address is zero");
      totalEthers += amounts[i];
    }
    require(msg.value == totalEthers, "Insufficient balance passed");
    for (uint i = 0; i < recipients.length; i++) {
      (bool success, ) = recipients[i].call{ value: amounts[i] }("");
      require(success, "BatchTransfer failed");
    }
    emit BatchTransfer(msg.sender, recipients, amounts);
  }

  fallback() external {}

  function simpleBatchTransferToken(
    address tokenAddress,
    address[] calldata recipients,
    uint256[] calldata amounts
  ) external nonReentrant {
    require(recipients.length == amounts.length,"The input arrays must have the same length");
    IERC20 requestedToken = IERC20(tokenAddress);
    for (uint256 i = 0; i < recipients.length; i++) {
      (bool status, ) = address(requestedToken).call(
        abi.encodeWithSignature(
          "transferFrom(address,address,uint256)",
          msg.sender,
          recipients[i],
          amounts[i]
        )
      );
      require(status, "BatchTransfer Token failed");
    }
    emit SimpleBatchTransferToken(
      msg.sender,
      tokenAddress,
      recipients,
      amounts
    );
  }

  function batchTransferMultiTokens(
    address[] calldata tokenAddress,
    address[] calldata recipients,
    uint256[] calldata amounts
  ) external nonReentrant {
    require(tokenAddress.length == recipients.length && tokenAddress.length == amounts.length, "The input arrays must have the same length");
    for (uint i = 0; i < tokenAddress.length; i++) {
      IERC20 requestedToken = IERC20(tokenAddress[i]);
      (bool success, ) = address(requestedToken).call(
        abi.encodeWithSignature(
          "transferFrom(address,address,uint256)",
          msg.sender,
          recipients[i],
          amounts[i]
        )
      );
      require(success, "BatchTransfer Token failed");
    }
    emit BatchTransferMultiToken(msg.sender, tokenAddress, recipients, amounts);
  }

  function batchTransferToken(
    address tokenAddress,
    address[] calldata recipients,
    uint256[] calldata amounts
  ) external nonReentrant {
    require(recipients.length == amounts.length,"The input arrays must have the same length");
    IERC20 requestedToken = IERC20(tokenAddress);
    uint256 amount = 0;

    for (uint256 i = 0; i < recipients.length; i++) {
      amount += amounts[i];
    }
    uint allowance = IERC20(tokenAddress).allowance(msg.sender, address(this));
    require(
      allowance >= amount,
      "Error: insufficient allowance provided to the contract"
    );
    (bool success, ) = address(requestedToken).call(abi.encodeWithSignature(
        "transferFrom(address,address,uint256)",msg.sender,address(this),amount)
    );
    require(success, "BatchTransfer Token failed");
    for (uint256 i = 0; i < recipients.length; i++) {
      (bool status, ) = address(requestedToken).call(abi.encodeWithSignature(
          "transfer(address,uint256)",recipients[i],amounts[i])
      );
      require(status, "BatchTransfer Token failed");
    }
    emit BatchTransferToken(msg.sender, tokenAddress, recipients, amounts);
  }

  function batchTransferCombinedMultiTokens(
    address[] calldata tokenAddress,
    address[] calldata tokenRecipients,
    uint256[] calldata tokenAmounts,
    address[] calldata recipients,
    uint256[] calldata amounts
  ) external payable nonReentrant {
    require(
      tokenAddress.length == tokenRecipients.length && tokenAddress.length == tokenAmounts.length && recipients.length == amounts.length,
      "The input arrays must have the same length"
    );
    uint256 totalEthers = 0;
    for (uint i = 0; i < recipients.length; i++) {
      require(recipients[i] != address(0), "Recipient address is zero");
      totalEthers += amounts[i];
    }
    require(msg.value == totalEthers, "Insufficient balance passed");
    for (uint i = 0; i < recipients.length; i++) {
      (bool success, ) = recipients[i].call{ value: amounts[i] }("");
      require(success, "BatchTransfer failed");
    }
    for (uint i = 0; i < tokenAddress.length; i++) {
      IERC20 requestedToken = IERC20(tokenAddress[i]);
      (bool success, ) = address(requestedToken).call(abi.encodeWithSignature(
        "transferFrom(address,address,uint256)",msg.sender,tokenRecipients[i],tokenAmounts[i])
      );
      require(success, "BatchTransfer Token failed");
    }
    emit BatchTransferCombinedMultiTokens(
      msg.sender,
      tokenAddress,
      tokenRecipients,
      tokenAmounts,
      recipients,
      amounts
    );
  }
}