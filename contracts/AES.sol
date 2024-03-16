// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract AES is ERC20 {
    address owner;

    constructor() ERC20("AES", "AES") {
        owner = msg.sender;
    }

    function burn(address account, uint256 amount) public virtual returns (bool) {
        require(owner == msg.sender);

        _burn(account, amount * 10**uint(decimals()));

        return true;
    }

    function mint(address account, uint256 amount) public virtual returns (bool) {
        require(owner == msg.sender);
        
        _mint(account, amount * 10**uint(decimals()));

        return true;
    }
}

//0x44282DB3b3536b0b5AA27dF77Ba4EcD01332dea1