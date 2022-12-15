// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveGovernanceV2} from 'aave-address-book/AaveAddressBook.sol';
import {AutonomousProposal, IAutonomousProposal} from './AutonomousProposal.sol';
import {ISimpleAutonomousProposal} from './interfaces/ISimpleAutonomousProposal.sol';

/**
 * @title Simple Autonomous Proposal
 * @author BGD Labs
 * @notice Contract implementing AutonomousProposal, that only requires to pass the necessary information
           to constructor to work. This contract is done to cover 90% of use cases, so proposers
           have an easy way of creating proposals.
 * @dev this contract assumes that the executor signature will always be `execute()` and will be called with
        delegateCall and value 0.
 * @dev if there is a need for more customisation the recommendation is to just implement AutonomousProposal and add
        custom logic.
 */
contract SimpleAutonomousProposal is
  AutonomousProposal,
  ISimpleAutonomousProposal
{
  /// @inheritdoc ISimpleAutonomousProposal
  address public immutable PAYLOAD;

  /// @inheritdoc ISimpleAutonomousProposal
  bytes32 public immutable IPFS_HASH;

  /// @inheritdoc ISimpleAutonomousProposal
  address public immutable EXECUTOR;

  bool internal _proposalCreated;
  uint256 internal _proposalId;

  ProposalParams internal _proposalParams;

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

    _proposalParams = ProposalParams({
      target: PAYLOAD,
      withDelegateCall: true,
      value: 0,
      signature: 'execute()',
      callData: ''
    });
  }

  /// @inheritdoc ISimpleAutonomousProposal
  function getProposalParams() external view returns (ProposalParams memory) {
    return _proposalParams;
  }

  /// @inheritdoc ISimpleAutonomousProposal
  function getProposalId() external view returns (uint256) {
    return _proposalId;
  }

  /// @inheritdoc ISimpleAutonomousProposal
  function isProposalCreated() external view returns (bool) {
    return _proposalCreated;
  }

  /// @inheritdoc IAutonomousProposal
  function create() external override inCreationWindow {
    require(!_proposalCreated, 'PROPOSAL_ALREADY_CREATED');

    ProposalParams[] memory proposalParamsList = new ProposalParams[](1);
    proposalParamsList[0] = _proposalParams;

    _proposalId = _createProposal(EXECUTOR, IPFS_HASH, proposalParamsList);

    _proposalCreated = true;
  }

  /// @inheritdoc IAutonomousProposal
  function vote() external override {
    require(_proposalCreated, 'PROPOSAL_NOT_CREATED');
    AaveGovernanceV2.GOV.submitVote(_proposalId, true);
  }
}
