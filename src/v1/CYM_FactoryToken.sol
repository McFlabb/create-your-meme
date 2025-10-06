// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { CYM_TokenContract } from "../helpers/CYM_TokenContract.sol";
//import { CYM_MultiSigContract } from "./CYM_MultiSigContract.sol";
//import { CYM_LiquidityManager } from "./CYM_LiquidityManager.sol";

/**
 * @title CYM_FactoryToken.
 * @notice A contract that creates new memecoin tokens and Uniswap liquidity pools for that tokens.
 * @dev Has persistant storage, MultiSigContract has volatile storage.
 * @dev This means past signed txs data is available in this contract for more functions
 * after tx is executed.
 */
contract CYM_FactoryToken is Ownable {
        ////////////////////
    // Custom Errors //
    //////////////////
    error FactoryTokenContract__onlyMultiSigContract();
}
