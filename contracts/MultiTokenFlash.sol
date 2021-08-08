pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IUniswapV2Factory.sol";
import "../interfaces/IUniswapV2Callee.sol";


contract MultiFlashSwap is IUniswapV2Callee{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private WETH;
    address private FACTORY;
    address private ROUTER;
    address private GOVERNATOR;

    uint public slippageFactor = 950;
    uint public slippageBP = 1000;
    uint256 MAX = 2**256 - 1;

    //create log
    event Log(string message, uint256 num);
    event Senders(string messg, address sendr);

    constructor(address _WETH, address _FACTORY, address _ROUTER) {
        WETH = _WETH;
        FACTORY = _FACTORY;
        ROUTER = _ROUTER;
        GOVERNATOR = msg.sender;

    }

    function setSettings(uint _slippageFactor, address _newRouter, address _newFactory) external {
        require(msg.sender==GOVERNATOR);
        slippageFactor = _slippageFactor;
        setDirection(_newRouter, _newFactory);
    }

    function setDirection(address _router, address _factory) internal {
        require(msg.sender==GOVERNATOR);
        ROUTER = _router;
        FACTORY = _factory;
    }

    
    function order66(address _tokenBorrow, uint256 _amount) external {
        //transfer enough to cover fee
        //not actually needed for a multitoken cuz fee is taken out from getAmountsIn()

    

        require(msg.sender==GOVERNATOR);
        //need LP pair address of given tokens.  We need to figure out if the token we are borrowing
        // is the first or second address of the pair, we wont know at first.
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenBorrow, WETH);
        require(pair != address(0), "This specific pair does not exist" );

        // duplicitous variables to get each token address from the pair
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        //if the address of the token to borrow is token [0] then borrow the amount, otherwise its 0 (0 because it deduces that the other is WETH which we arent borrowing.)
        //however, if the address of token to borrow is token [1] then borrow the amount, otherwise its 0
        //handy way of deciding one or the other in a binary choice
        uint amount0Out = _tokenBorrow == token0 ? _amount : 0;
        uint amount1Out = _tokenBorrow == token1 ? _amount : 0;

        // hers the acutal swap
        //what makes this unique is we're calling the swap on the pair pool contract, not the v2router :))
        // we call this swap function here, and then the UniV2Pair contract calls the UniswapV2Call function below

        bytes memory data = abi.encode(_tokenBorrow, _amount);

        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    function uniswapV2Call(address _sender, uint _amount0, uint _amount1, bytes calldata _data) external override {
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        address pair = IUniswapV2Factory(FACTORY).getPair(token0, token1);
        require(msg.sender == pair, "Caller is Not the Pair Address, Please Use Pair address");
        //this is confusing but, below we need to check to see if the _sender of UniswapV2Call() is this contract
        require(_sender == address(this), "_sender must be this Contracts own address");

        // now we need to decode the _data that we encoded above
        (address tokenBorrow, uint amount) = abi.decode(_data, (address, uint));



        // Do STUFF HERE LIKE REALLY COOL STUFF.
        // well just log for now
        emit Log("amount to borrow ", amount);
        emit Log("amount0 ", _amount0);
        emit Log("amount1 ", _amount1);

        emit Senders("who requested the loan?", _sender);
        emit Senders("Which pair made the call to swap?", msg.sender);
        emit Senders("Which Pair are we trading?", pair);


        address[] memory path = new address[](2);
        path[0] = tokenBorrow;
        path[1] = WETH;

        setAllowances(tokenBorrow);

        // sell borrowed tokens on counterparty's router
        _safeSwap(tokenBorrow, WETH, amount, address(this));

        uint256 shortBalance = IERC20(WETH).balanceOf(address(this));



        //handle fee
        uint256[] memory amounts = IUniswapV2Router(ROUTER).getAmountsIn(amount, path);
        uint256 balanceDue = amounts[amounts.length.sub(1)];
        emit Log("short balance", shortBalance);
        emit Log("repayment amount", balanceDue);

        require(shortBalance > balanceDue);


        // finally we repay by transferring the amount o repay of token we borrowed back to the pair
        IERC20(tokenBorrow).safeTransfer(pair, balanceDue);

        //sweep the profits
        uint256 netProfit = IERC20(tokenBorrow).balanceOf(address(this));
        emit Log("net profit", netProfit);
        IERC20(tokenBorrow).safeTransfer(tx.origin, netProfit);





    }




    function _findPath(address _tokenIn) public returns (address[] memory _path) {
        address[] memory path;
        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = WETH;
        return path;
    }

    function _safeSwap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        address _to
    ) internal {

        address[] memory _path = _findPath(_tokenIn);



        uint256[] memory amounts = IUniswapV2Router(ROUTER).getAmountsOut(_amountIn, _path);
        uint256 amountOut = amounts[amounts.length.sub(1)];

        IUniswapV2Router(ROUTER).swapExactTokensForTokens(
            _amountIn,
            amountOut.mul(slippageFactor).div(slippageBP),
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

    function setAllowances(address _tokenIn) internal {

        IERC20(_tokenIn).safeApprove(ROUTER, uint256(0));
        IERC20(_tokenIn).safeIncreaseAllowance(
            ROUTER,
            MAX
        );

    }


}