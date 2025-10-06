// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { CYM_TokenContract } from "../helpers/CYM_TokenContract.sol";
import { CYM_MultiSigContract } from "./CYM_MultiSigContract.sol";
import { CYM_LiquidityManager } from "./CYM_LiquidityManager.sol";

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
    error TransactionAlreadyExecuted();
    error InvalidSignerCount();
    error InvalidSupply();
    error EmptyName();
    error EmptySymbol();

    /**
     * @notice Structs.
     */
    struct TxData {
        uint256 txId;
        address owner;
        address[] signers;
        bool isPending;
        string tokenName;
        string tokenSymbol;
        uint256 totalSupply;
        uint256 maxSupply;
        bool canMint;
        bool canBurn;
        bool supplyCapEnabled;
        address tokenAddress;
        string ipfsHash;
    }
    
    /**
     * @notice Variables.
     */
    CYM_MultiSigContract public multiSigContract;
    CYM_LiquidityManager public liquidityManager;
    TxData[] public txArray;
    uint256 public TX_ID;
    address public USDC_ADDRESS;

    constructor(
        address _multiSigContract,
        address _liquidityManager,
        address _USDC,
        address initialOwner
    )
        Ownable(initialOwner)
    {
        multiSigContract = MultiSigContract(_multiSigContract);
        liquidityManager = LiquidityManager(_liquidityManager);
        TxData memory constructorTx = TxData({
            txId: 0,
            owner: address(0),
            signers: new address[](0),
            isPending: true,
            tokenName: "",
            tokenSymbol: "",
            totalSupply: 0,
            maxSupply: 0,
            canMint: false,
            canBurn: false,
            supplyCapEnabled: false,
            tokenAddress: address(0),
            ipfsHash: ""
        });
        txArray.push(constructorTx);
        ownerToTxId[address(0)] = 0;
        TX_ID = 1;
        USDC_ADDRESS = _USDC;
    }
}
