// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./libs/ERC20.sol";
import "./libs/Ownable.sol";

/**
 * @dev xFIL token contract
 */
contract XFIL is Ownable, ERC20 {
    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed burner, uint256 amount);

    uint256 private initialized;

    constructor(address _owner) Ownable(_owner) ERC20("", "") {
        initialized = 1;
    }

    function initialize(address _owner) external {
        require(initialized == 0, "xFIL: already initialized");
        initialized = 1;

        require(_owner != address(0x0), "xFIL: owner is zero");
        _name = "xFIL";
        _symbol = "xFIL";
        _setOwner(_owner);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing the total supply.
     */
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
        emit Mint(account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from sender, reducing the total supply.
     */
    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }

    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
    }
}
