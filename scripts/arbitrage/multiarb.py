from brownie import *
import os

def deploy():
    dev = accounts.add(os.getenv("PRIVATE_KEY"))


    WETH = "0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270"
    ROUTER = "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506" #sushi router
    FACTORY = "0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32" #quick factory

    txn = MultiFlashSwap.deploy(WETH, FACTORY, ROUTER, {"from": dev})

    return txn

def setSettings(slippage, router, factory):
    dev = accounts.add(os.getenv("PRIVATE_KEY"))
    
    txn = MultiFlashSwap[-1].setSettings(slippage, router, factory, {"from": dev})

    return txn


def arb():
    dev = accounts.add(os.getenv("PRIVATE_KEY"))
    token = "0x3a3df212b7aa91aa0402b9035b098891d276572b" #fish
    amount = 2 * 1e18


    txn = MultiFlashSwap[-1].order66(token, amount, {"from": dev, "gas_price": 15000000000, "gas_limit": 1000000, "allow_revert": True})



