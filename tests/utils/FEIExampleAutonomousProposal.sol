// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveGovernanceV2} from 'aave-address-book/AaveAddressBook.sol';
import {AutonomousProposal} from '../src/contracts/AutonomousProposal.sol';

contract FEIExampleAutonomousProposal is AutonomousProposal {
  address public immutable PAYLOAD;
  bytes32 public immutable IPFS_HASH;

  bool public proposalCreated;
  uint256 public proposalId;

  constructor(
    address payload,
    bytes32 ipfsHash,
    uint256 proposalCreationTimestamp
  ) AutonomousProposal(proposalCreationTimestamp) {
    PAYLOAD = payload;
    IPFS_HASH = ipfsHash;
  }

  function create() external override inCreationWindow {
    require(!proposalCreated, 'PROPOSAL_ALREADY_CREATED');

    ProposalParams[] memory proposalParams = new ProposalParams[](1);
    proposalParams[0] = ProposalParams({
      target: PAYLOAD,
      widthDelegateCall: true,
      value: 0,
      signature: 'execute()',
      callData: ''
    });

    proposalId = _createProposal(
      AaveGovernanceV2.SHORT_EXECUTOR,
      IPFS_HASH,
      proposalParams
    );

    proposalCreated = true;
  }

  function vote() external override {
    require(proposalCreated, 'PROPOSAL_NOT_CREATED');
    AaveGovernanceV2.GOV.submitVote(proposalId, true);
  }
}
