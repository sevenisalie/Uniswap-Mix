from brownie import *
import os

def main():
    factory = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f" #uni mainnet factory
    wsushifactory = "0xc35DADB65012eC5796536bD9864eD8773aBc74C4"
    weth = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2" #i've vetted this to be the true weth, future me 
    wmatic = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270"
    dev = accounts.add(os.getenv("PRIVATE_KEY"))
    forkeddev = accounts.at('0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE', force=True)
    FlashSwap.deploy(wmatic, wsushifactory, {'from': dev})