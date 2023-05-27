// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PropertyToken is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 maxSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, maxSupply);
    }
}
