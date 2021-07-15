//SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

struct SuccessMarketDataStructure {
    uint256 marketTotalToken;
    address[] destinations;
    uint256[] tokens;
    uint256 creatorFee;
    uint256 cojamFee;
    uint256 charityFee;
    uint256 balanceTokens;
}
