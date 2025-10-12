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

    /**
     * @notice Mappings.
     */
    mapping(address => uint256) public ownerToTxId;

    /**
     * @notice Events.
     */
    event TransactionQueued(
        uint256 indexed txId, address indexed owner, address[] signers, string tokenName, string tokenSymbol
    );

    /// @notice Emit when a new token is created
    event MemecoinCreated(
        address indexed owner, address indexed tokenAddress, string indexed name, string symbol, uint256 supply
    );

    /**
     * @notice Modifiers.
     */
    modifier onlyMultiSigContract() {
        if (msg.sender != address(multiSigContract)) {
            revert FactoryTokenContract__onlyMultiSigContract();
        }
        _;
    }

    /// @notice modifier to ensure only pending txs can be executed
    modifier onlyPendigTx(uint256 _txId) {
        if (!txArray[_txId].isPending) {
            revert TransactionAlreadyExecuted();
        }
        _;
    }

    constructor(
        address _multiSigContract,
        address _liquidityManager,
        address _USDC,
        address initialOwner
    )
        Ownable(initialOwner)
    {
        multiSigContract = CYM_MultiSigContract(_multiSigContract);
        liquidityManager = CYM_LiquidityManager(_liquidityManager);
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

    /**
     * @notice Creates a pending transaction to initialize a new meme token.
     * @dev Actual token creation happens once the MultiSigContract approves the transaction.
     * @param _signers The list of signers required to approve this transaction in the MultiSigContract.
     * @param _owner The address of the token owner.
     * @param _tokenName The name of the token to be created.
     * @param _tokenSymbol The symbol of the token to be created.
     * @param _totalSupply The initial token supply.
     * @param _maxSupply The maximum token supply, if a cap is enabled.
     * @param _canMint Whether the token has minting capabilities.
     * @param _canBurn Whether the token has burning capabilities.
     * @param _supplyCapEnabled Whether the token has a supply cap.
     * @return txId The ID of the newly created transaction.
     */
    function queueCreateMemecoin(
        address[] memory _signers,
        address _owner,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _totalSupply,
        uint256 _maxSupply,
        bool _canMint,
        bool _canBurn,
        bool _supplyCapEnabled,
        string memory _ipfsHash
    )
        external
        returns (uint256 txId)
    {
        if (_signers.length < 2) {
            revert InvalidSignerCount();
        }
        if (bytes(_tokenName).length == 0) {
            revert EmptyName();
        }
        if (bytes(_tokenSymbol).length == 0) {
            revert EmptySymbol();
        }
        if (_totalSupply <= 0) {
            if (_supplyCapEnabled) {
                if (_maxSupply < _totalSupply) {
                    revert InvalidSupply();
                }
            }
            if (_maxSupply < _totalSupply) {
                revert InvalidSupply();
            }
        }
        txId = _handleQueue(
            _signers,
            _owner,
            _tokenName,
            _tokenSymbol,
            _totalSupply,
            _maxSupply,
            _canMint,
            _canBurn,
            _supplyCapEnabled,
            _ipfsHash
        );
    }

    /**
     * @notice Completes the pending transaction to create the meme token after MultiSigContract approval.
     * @param _txId The ID of the transaction to be executed.
     * @dev Callable only by the MultiSigContract once all required signatures are collected.
     */
    function executeCreateMemecoin(uint256 _txId) public onlyMultiSigContract onlyPendigTx(_txId) {
        _createMemecoin(_txId);
    }

    /**
     * @notice Fetches transaction data for a given transaction ID.
     * @param _txId The ID of the transaction to fetch.
     * @return TxData memory The transaction data for the specified ID.
     */
        function getTxData(uint256 _txId) external view returns (TxData memory) {
        return txArray[_txId];
    }

    function _handleQueue(
        address[] memory _signers,
        address _owner,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _totalSupply,
        uint256 _maxSupply,
        bool _canMint,
        bool _canBurn,
        bool _supplyCapEnabled,
        string memory _ipfsHash
    )
        internal
        returns (uint256 txId)
    {
        TxData memory tempTx = TxData({
            txId: TX_ID,
            owner: _owner,
            signers: _signers,
            isPending: true,
            tokenName: _tokenName,
            tokenSymbol: _tokenSymbol,
            totalSupply: _totalSupply,
            maxSupply: _maxSupply,
            canMint: _canMint,
            canBurn: _canBurn,
            supplyCapEnabled: _supplyCapEnabled,
            tokenAddress: address(0),
            ipfsHash: _ipfsHash
        });
        txArray.push(tempTx);
        ownerToTxId[_owner] = TX_ID;
        multiSigContract.queueTx(TX_ID, _owner, _signers);
        emit TransactionQueued(TX_ID, _owner, _signers, _tokenName, _tokenSymbol);
        txId = TX_ID;
        TX_ID += 1;
    }
}
