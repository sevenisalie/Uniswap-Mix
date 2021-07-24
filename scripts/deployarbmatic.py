
from brownie import *
import os
##borrow on factory, sell on router
def main():
    factory = "0xc35DADB65012eC5796536bD9864eD8773aBc74C4" #quick mainnet factory
    wmatic = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270" #i've vetted this to be the true weth, future me
    router = "0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff" #quick mainnet router
    dev = accounts.add(os.getenv("PRIVATE_KEY"))
    #forkeddev = accounts.at('0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE', force=True)
    Arbitrage.deploy(factory, router, {'from': dev})