pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../interfaces/IUniswapV2Router.sol";


contract ChefSwap {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address ROUTER;
    address WETH;
    address GOVERNATOR;
    uint256 MAX = 2**256 - 1;

    uint slippageFactor = 950;
    uint slippageBP = 1000;

    constructor(address _router, address _weth) {
        GOVERNATOR = msg.sender;
        ROUTER = _router;
        WETH = _weth;
        

    }

    function setSlippage(uint256 slippage) external {
        require(msg.sender==GOVERNATOR);

        slippageFactor = slippage;

    }

    function setAllowances(address _tokenIn) internal {

        IERC20(_tokenIn).safeApprove(ROUTER, uint256(0));
        IERC20(_tokenIn).safeIncreaseAllowance(
            ROUTER,
            MAX
        );

    }

    function order66(uint _amountIn, address _tokenIn, address _tokenOut) external returns(uint256 newBalance) {

        require(msg.sender==GOVERNATOR);

        setAllowances(_tokenIn);

        _deposit(_amountIn, _tokenIn);



        _safeSwap(
            _tokenIn,
            _tokenOut,
            _amountIn,
            msg.sender //test this line to something else/ check if need approval etc, this is where issue lies methinks
        
        );

        newBalance = IERC20(_tokenOut).balanceOf(address(this));
        _withdraw(_tokenOut);
        return newBalance;
    }

    function _findPath(address _tokenIn, address _tokenOut) public returns (address[] memory _path) {
        address[] memory path;
        path = new address[](3);
        path[0] = _tokenIn;
        path[1] = WETH;
        path[2] = _tokenOut;
        return path;
    }

    function _safeSwap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        address _to
    ) internal {

        address[] memory _path = _findPath(_tokenIn, _tokenOut);



        uint256[] memory amounts = IUniswapV2Router(ROUTER).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length.sub(1)];

        IUniswapV2Router(ROUTER).swapExactTokensForTokens(
            _amountIn,
            amountOut.mul(slippageFactor).div(1000),
            _path,
            _to,
            block.timestamp.add(600)
        );
    }


    function _deposit(uint256 amount, address token) internal {
        require(msg.sender == GOVERNATOR);
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }

    function _withdraw(address token) internal {
        require(msg.sender == GOVERNATOR);
        uint256 wantAmt = IERC20(token).balanceOf(address(this));

        IERC20(token).safeTransfer(msg.sender, wantAmt);


    }
}