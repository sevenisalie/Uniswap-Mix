pragma solidity ^0.8.0;

import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IUniswapV2Factory.sol";
import "../interfaces/IUniswapV2Callee.sol";


contract FlashSwap is IUniswapV2Callee{

    address private WETH;
    address private FACTORY;

    //create log
    event Log(string message, uint256 num);
    event Senders(string messg, address sendr);

    constructor(address _WETH, address _FACTORY) {
        WETH = _WETH;
        FACTORY = _FACTORY;
    }

    
    function testFlashSwap(address _tokenBorrow, uint256 _amount) external {
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

        //handle fee
        uint fee = ((amount * 3) / 997) +1;
        uint amountToRepay = amount + fee;

        // Do STUFF HERE LIKE REALLY COOL STUFF.
        // well just log for now

        //crossed market (factory to short on aka asset borrowed is priced more expensive on thsi factory so sellit)
      




        emit Log("amount to borrow ", amount);
        emit Log("amount0 ", _amount0);
        emit Log("amount1 ", _amount1);
        emit Log("fee ", fee);
        emit Log("Total to repay flash ", amountToRepay);
        emit Senders("who requested the loan?", _sender);
        emit Senders("Which pair made the call to swap?", msg.sender);
        emit Senders("Which Pair are we trading?", pair);

        // finall we repay by transferring the amount o repay of token we borrowed back to the pair
        IERC20(tokenBorrow).transfer(pair, amountToRepay);


    }


}