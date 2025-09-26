// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SuperStar is ERC20 {
    constructor() ERC20("Super Star", "Star") {
        _mint(msg.sender, 100000000 * 10**18); 
    }
}