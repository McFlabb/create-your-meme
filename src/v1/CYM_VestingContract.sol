// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CYM_LiquidityManager.sol";

/**
 * @title CYM_VestingContract
 * @author CraftMeme
 * @dev Implements a token vesting schedule to release tokens over time to beneficiaries.
 * @notice This contract allows the owner to set vesting schedules and beneficiaries to claim vested tokens over time.
 */
contract CYM_VestingContract {
    ////////////////////
    // Custom Errors //
    //////////////////
    error VestingAlreadySet();
    error NoVestingSchedule();
    error VestingIsRevoked();
    error NoTokensAreDue();
    error AlreadyRevoked();

    //////////////////////
    // State variables //
    ////////////////////
    /// @notice SafeERC20 is used for token transfers
    using SafeERC20 for IERC20;

    /// @notice Liquidity manager contract
    CYM_LiquidityManager liquidityManager;

    /// @notice Struct to store vesting schedule data
    struct VestingSchedule {
        address tokenAddress;
        uint256 start;
        uint256 duration;
        uint256 amount;
        uint256 released;
        bool revoked;
    }

    /// @notice Mapping to store vesting schedules
    mapping(address => VestingSchedule) private vestingSchedules;

    /////////////
    // Events //
    ///////////
    /// @notice Emit when tokens are released
    event TokensReleased(address indexed beneficiary, uint256 indexed amount);

    /// @notice Emit when a vesting schedule is revoked
    event VestingRevoked(address indexed beneficiary);

    ////////////////
    // Functions //
    //////////////
    /**
     * @param InitialOwner The initial owner of the contract.
     */
    constructor(address InitialOwner) Ownable(InitialOwner) { }
}
