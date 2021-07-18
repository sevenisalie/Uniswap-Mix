from brownie import *
import os

def main():
    router = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D" #uni mainnet router
    weth = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2" #i've vetted this to be the true weth, future me
    dev = accounts.add(os.getenv("PRIVATE_KEY"))
    forkeddev = accounts.at('0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE', force=True)
    Swappy.deploy(router, weth, {'from': forkeddev})