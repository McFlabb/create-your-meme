// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { CYM_FactoryToken } from "./CYM_FactoryToken.sol";
import { ISP } from "@signprotocol/signprotocol-evm/src/interfaces/ISP.sol";
import { Attestation } from "@signprotocol/signprotocol-evm/src/models/Attestation.sol";
import { DataLocation } from "@signprotocol/signprotocol-evm/src/models/DataLocation.sol";

/**
 * @title CYM_MultiSigContract
 * @author create-your-meme
 * @dev A multisig contract requiring multiple signers to approve transactions, adding decentralization and security.
 * Integrates Sign Protocol to manage on-chain signature attestations for enhanced transparency and validation.
 * @notice Works with FactoryTokenContract for meme token creation, with signers validating transactions.
 */
contract CYM_MultiSigContract is Ownable {
    //////////////////////
    // State variables //
    ////////////////////
    /// @notice Reference to the factory token contract used for token creation.
    CYM_FactoryToken public factoryTokenContract;

    /// @notice Sign Protocol instance used for attestations.
    ISP public spInstance;

    /// @notice Unique ID for the signature schema within the Sign Protocol.
    uint64 public signatureSchemaId;

    ////////////////
    // Functions //
    //////////////
    /**
     * @param _spInstance Address of the Sign Protocol instance.
     * @param _signatureSchemaId Unique schema ID for signature verification within Sign Protocol.
     */
    constructor(address _spInstance, uint64 _signatureSchemaId) Ownable(msg.sender) {
        spInstance = ISP(_spInstance);
        signatureSchemaId = _signatureSchemaId;
    }
}
