// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC20Pausable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

/**
 * @title CYM_TokenContract
 * @author CraftMeme
 * @dev A customizable ERC20 token contract with minting, burning, and pausable features.
 * This contract allows the owner to mint and burn tokens based on configuration. Additionally,
 * the contract can pause or unpause all token transfers.
 *
 * Inherits from OpenZeppelin's ERC20, ERC20Pausable, and Ownable contracts.
 */
contract CYM_TokenContract is ERC20, ERC20Pausable, Ownable {
        ////////////////////
    // Custom Errors //
    //////////////////
        error MintingIsDisabled();
            error BurningIsDisabled();
    error MaxSupplyReached();

    //////////////////////
    // State variables //
    ////////////////////

    /// @notice Initial supply of the token minted at deployment
       uint256 private initialSupply;

    /// @notice Max supply of the token
        uint256 private maxSupply;

    /// @notice Total supply of the token
    bool private supplyCapEnabled;

    /// @notice Whether the token can be minted
    bool private canMint;

    /// @notice Whether the token can be burned
    bool private canBurn;

    /////////////
    // Events //
    ///////////
    /// @notice Emit when a new token is minted
    event Mint(address indexed from, uint256 indexed amount);

}
