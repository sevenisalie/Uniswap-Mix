from brownie import *

def main(deployedSwapContract, version):
    router = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"
    weth = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2" #i've vetted this to be the true weth, future me
    USDC = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"
    DAI = "0x6b175474e89094c44da98b954eedeac495271d0f"
    AAVE = "0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9"

    whale = "0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE"


    whalesignature = accounts.at('0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE', force=True)


    tokenborrow = AAVE
    amount = 20000 * 1e18
    fee = int((amount * 0.003)) + 1
    totalamountapprove = amount + fee +2
    frm = {"from": whalesignature}
    balance = {}
    #approve token to be spent by our contract
    ITokenIn = interface.IERC20(tokenborrow)
    balance["balancebefore"] = ITokenIn.balanceOf(whale)
    ITokenIn.approve(deployedSwapContract, totalamountapprove, frm)
    # ITokenIn.approve(Swappy[0].address, amountIn, frm)      ##if from console

    #swap
    tx = FlashSwap[version].testFlashSwap(tokenborrow, amount, frm)

    balance["balanceafter"] = ITokenIn.balanceOf(whale)
    return tx, print(balance)












##punch this into the brownie console
#tx = main(FlashSwap[0].address, 0)