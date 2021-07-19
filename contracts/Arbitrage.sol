pragma solidity ^0.8.0;

import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IUniswapV2Factory.sol";

import "./UniswapV2Library.sol";


contract Arbitrage {

    //constants
    address public FACTORY;
    IUniswapV2Router public ROUTER;
    uint constant deadline = 1 days;

    event Log(string msg, uint num);
    event LogAddresses(string msg1, address adrs);

    constructor(address _factoryofA, address _routerofB) {
        FACTORY = _factoryofA;
        ROUTER = IUniswapV2Router(_routerofB);
    }
    //token 0 is dai, token 1 is eth
    //UNISWAP eth is 2000
    //SUSHI eth is 2200
    function Order66(address _token0, address _token1, uint256 _amount0, uint256 _amount1) external {
        //get address pair off of Uniswap Factory
        address pair = IUniswapV2Factory(FACTORY).getPair(_token0, _token1);
        require(pair != address(0), "Pair does not exist");

        //Perform flash loan
        bytes memory data = abi.encode(_token0, _amount0, _token1, _amount1, pair);
        IUniswapV2Pair(pair).swap(_amount0, _amount1, address(this), data);

    }

    function uniswapV2Call(address _sender, uint _amount0, uint _amount1, bytes calldata _data) external {

        //security
        require(_sender == address(this), "_sender must be this Contracts own address");

        //figure out amount of and which token is being borrowed
        uint amountTokenBorrowed = _amount0 == 0 ? _amount1 : _amount0;

        //determine new path for trade (we love path dont we)

        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();

        address[] memory path = new address[](2);
        path[0] = _amount0 == 0 ? token1 : token0;
        path[1] = _amount0 == 0 ? token0 : token1;

        //security
        address pair = IUniswapV2Factory(FACTORY).getPair(token0, token1);
        require(msg.sender == pair, "Caller is Not the Pair Address, Please Use Pair address");
        require(_amount0 == 0 || _amount1 == 0, "One token amount must be 0");

        //approve spending of token borrowed.  remember path0 logic entails taht will always be the one we borrowed
        //remember we actually are trading with the sushi router despite borrowing and calling the unipair, need approval on contra firm
        IERC20 tokenborrowed = IERC20(_amount0 == 0 ? token1 : token0);
        tokenborrowed.approve(address(ROUTER), amountTokenBorrowed);

        //make the trade
        //we are also calling the specific values of those functions' return which is why we need the array slices
        //the Factory Pair is the one techincally calling SwapTokenforTOken, so they need to be the recipient of trade

        uint amountRequired = UniswapV2Library.getAmountsIn(FACTORY, amountTokenBorrowed, path)[0];

        uint amountReceived = ROUTER.swapExactTokensForTokens(amountTokenBorrowed, amountRequired, path, msg.sender, deadline)[1];

        //handle fee profitability security
        uint take = amountRequired - amountReceived;
        require(
            take > 0, "Unprofitable with trade fee of 0.3%"
        );

        //now we need to handle repayment.  at this point we have used the borrowed funds to buy the cheaper Token,
        //we now need to return that cheaper token back to the original Factory, and thus repay our loan

        IERC20 tokenReceived = IERC20(_amount0 == 0 ? token0 : token1);
        tokenReceived.transfer(msg.sender, amountRequired);
        tokenReceived.transfer(tx.origin, amountRequired - amountReceived);

        
        emit LogAddresses("transaction origin", tx.origin);
        emit Log("total borrowed", amountTokenBorrowed);
        emit LogAddresses("token borrowed", path[0]);
        emit Log("amount of other token required to finish swap", amountRequired);
        emit LogAddresses("token received", path[1]);
        emit Log("borrowed tokens sold for", amountReceived);
        emit Log("total profit", take);













    }
    


}