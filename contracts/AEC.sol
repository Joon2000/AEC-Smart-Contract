// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract AEC is ERC20 {
    address owner;

    constructor() ERC20("AEC", "AEC") {
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

//0xb07959116C226f4e5A089B9453Ac3370cD882b08