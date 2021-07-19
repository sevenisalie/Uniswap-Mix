
from brownie import *
import os

def main():
    factory = "0x3ab5dcf8e7ab97543Dac941fA2343c527837d329" #quick mainnet factory
    wmatic = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270" #i've vetted this to be the true weth, future me
    router = "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506" #quick mainnet router
    dev = accounts.add(os.getenv("PRIVATE_KEY"))
    #forkeddev = accounts.at('0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE', force=True)
    Arbitrage.deploy(factory, router, {'from': dev})