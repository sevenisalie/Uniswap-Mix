from brownie import *


def main(deployedSwapContract, version):
    WMATIC = "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270" #i've vetted this to be the true weth, future me
    USDC = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"
    DAI = "0x6b175474e89094c44da98b954eedeac495271d0f"
    mFISH = "0x3a3Df212b7AA91Aa0402B9035b098891d276572B"

    sender = "0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE"


    whalesignature = accounts.at('0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE', force=True)
    dev = accounts.add(os.getenv("PRIVATE_KEY"))

    tokenborrow = mFISH
    amount = 25 * 1e18
    fee = int((amount * 0.003)) + 1
    totalamountapprove = amount + fee +2
    frm = {"from": dev}
    balance = {}
    #approve token to be spent by our contract
    ITokenIn = interface.IERC20(tokenborrow)
    balance["balancebefore"] = ITokenIn.balanceOf(sender)
    ITokenIn.approve(deployedSwapContract, totalamountapprove, frm)
    # ITokenIn.approve(Swappy[0].address, amountIn, frm)      ##if from console

    #swap
    tx = FlashSwap[version].testFlashSwap(tokenborrow, amount, frm)

    balance["balanceafter"] = ITokenIn.balanceOf(sender)
    return tx, print(balance)












##punch this into the brownie console
#tx = main(FlashSwap[0].address, 0)