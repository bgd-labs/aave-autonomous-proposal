// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveGovernanceV2} from 'aave-address-book/AaveAddressBook.sol';
import './AutonomousProposal.sol';

contract SimpleAutonomousProposal is AutonomousProposal {
  address public immutable PAYLOAD;
  bytes32 public immutable IPFS_HASH;
  address public immutable EXECUTOR;

  bool public proposalCreated;
  uint256 public proposalId;

  ProposalParams public proposalParams;

  constructor(
    address payload,
    bytes32 ipfsHash,
    address executor,
    uint256 proposalCreationTimestamp
  ) AutonomousProposal(proposalCreationTimestamp) {
    require(payload != address(0), 'PAYLOAD_ADDRESS_0');
    require(ipfsHash != bytes32(0), 'PAYLOAD_IPFS_HASH_BYTES32_0');
    require(
      executor == AaveGovernanceV2.SHORT_EXECUTOR ||
        executor == AaveGovernanceV2.LONG_EXECUTOR,
      'INCORRECT_EXECUTOR'
    );

    PAYLOAD = payload;
    IPFS_HASH = ipfsHash;
    EXECUTOR = executor;

    proposalParams = ProposalParams({
      target: PAYLOAD,
      withDelegateCall: true,
      value: 0,
      signature: 'execute()',
      callData: ''
    });
  }

  function create() external override inCreationWindow {
    require(!proposalCreated, 'PROPOSAL_ALREADY_CREATED');

    ProposalParams[] memory proposalParamsList = new ProposalParams[](1);
    proposalParamsList[0] = proposalParams;

    proposalId = _createProposal(EXECUTOR, IPFS_HASH, proposalParamsList);

    proposalCreated = true;
  }

  function vote() external override {
    require(proposalCreated, 'PROPOSAL_NOT_CREATED');
    AaveGovernanceV2.GOV.submitVote(proposalId, true);
  }
}
