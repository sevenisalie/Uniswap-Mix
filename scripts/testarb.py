from brownie import *
import os


token0 = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2" #weth

token1 = "0xba100000625a3754423978a60c9317c58a424e3d" #balancer

amount0 = 10 * 10e18
amount1 = 0

def trade(token0, token1, amount0, amount1):
    tx = Arbitrage[0].Order66(token0, token1, amount0, amount1)
    return tx
