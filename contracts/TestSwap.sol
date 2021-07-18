pragma solidity ^0.8.0;


import "../interfaces/IERC20.sol";
import "../interfaces/IUniswapV2Router.sol";

contract Swappy {
   address private UNISWAP_V2_ROUTER;
   address private WETH;

   constructor(address _router, address _weth) {
       UNISWAP_V2_ROUTER = _router;
       WETH = _weth;
   }

   function Swap(
       address _tokenIn,
       address _tokenOut,
       uint256 _amountIn,
       uint256 _amountOut,
       address _to
   ) external {
       //we need to approve tokenIn & then transferfrom sender to this contract so that this contract has the funds to swap
       IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
       IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

       //next we need to handle the path - heres a trick for creating a dynamic list of x length in this case x=3

       address[] memory path;
       path = new address[](3);
       path[0] = _tokenIn;
       path[1] = WETH;
       path[2] = _tokenOut;

       // now we have the ingredients cookin to make a swap happen dont we now?

       IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
           _amountIn,
           _amountOut,
           path,
           _to,
           block.timestamp
       );


   }


}