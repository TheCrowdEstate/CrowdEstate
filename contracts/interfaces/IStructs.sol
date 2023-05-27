// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IStructs {
    struct Property {
        string name;
        string location;
        string[] images;
        uint256 price;
        uint256 shares;
        uint256 soldShares;
        mapping(address => uint256) balances;
    }
}
