//SPDX-License-Identifier: MIT
pragma solidity 0.7.1;

struct Betting {
    uint256 marketKey;
    uint256 answerKey;
    address voter;
    uint256 tokens;
    uint createTime;
    bool exist;
}

