from brownie import *
import os

def deploy():
    dev = accounts.add(os.getenv("PRIVATE_KEY"))
    tx = ChefSwap.deploy("0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506", 
    "0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270", 
    {"from": dev}
    )
    return tx

def swap():
    dev = accounts.add(os.getenv("PRIVATE_KEY"))
    tokenOut = "0x2791bca1f2de4661ed88a30c99a7a9449aa84174" #USDC
    tokenIn = "0xAa9654BECca45B5BDFA5ac646c939C62b527D394" #DINO
    amountIn = int(0.45 * 1e18)
    tx = ChefSwap[-1].order66(amountIn, tokenIn, tokenOut, {"from": dev})
    return tx

def approveUSDC():
    dev = accounts.add(os.getenv("PRIVATE_KEY"))
    USDC = interface.IERC20("0x2791bca1f2de4661ed88a30c99a7a9449aa84174")
    USDC.approve(ChefSwap[-1].address, 1000000000000000, {"from": dev}) #why does approve() work but not safeApprove() this is probably a big issue, interestingly safeApprove DOES work in the contract.

def approveDINO():
    dev = accounts.add(os.getenv("PRIVATE_KEY"))
    DINO = interface.IERC20("0xAa9654BECca45B5BDFA5ac646c939C62b527D394")
    DINO.approve(ChefSwap[-1].address, 10 * 1e18, {"from": dev})
    
def howmanyhaveifuckingdeployed():
    amt = len(ChefSwap)
    return amt