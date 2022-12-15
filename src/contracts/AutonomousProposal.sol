// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveGovernanceV2, IExecutorWithTimelock, IGovernanceStrategy} from 'aave-address-book/AaveGovernanceV2.sol';
import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {SafeERC20} from 'solidity-utils/contracts/oz-common/SafeERC20.sol';
import {IAutonomousProposal} from './interfaces/IAutonomousProposal.sol';

/**
 * @title Autonomous Proposal
 * @author BGD Labs
 * @notice Abstract contract implementing only generic logic for an autonomous proposal. Only
           checking for creating window, and implementing a generic internal method to create a proposal on
           governance contract
 * @dev Implement create method with the necessary logic to construct the proposal or proposals parameters necessary
        for creation.
 * @dev Implement vote method with the necessary logic to call governance proposal vote method.
 */
abstract contract AutonomousProposal is IAutonomousProposal {
  using SafeERC20 for IERC20;

  uint256 public immutable PROPOSALS_CREATION_TIMESTAMP;

  uint256 public constant GRACE_PERIOD = 5 days;

  /// @dev checks that proposal is on the creation window.
  modifier inCreationWindow() {
    require(
      block.timestamp > PROPOSALS_CREATION_TIMESTAMP,
      'CREATION_TIMESTAMP_NOT_YET_REACHED'
    );
    require(
      block.timestamp < PROPOSALS_CREATION_TIMESTAMP + GRACE_PERIOD,
      'TIMESTAMP_BIGGER_THAN_GRACE_PERIOD'
    );
    _;
  }

  /**
   * @dev Constructor.
   * @param creationTimestamp timestamp in seconds from when the proposals can be created
   */
  constructor(uint256 creationTimestamp) {
    require(creationTimestamp > block.timestamp, 'CREATION_TIMESTAMP_TO_EARLY');
    PROPOSALS_CREATION_TIMESTAMP = creationTimestamp;
  }

  /// @inheritdoc IAutonomousProposal
  function create() external virtual;

  /// @inheritdoc IAutonomousProposal
  function vote() external virtual;

  /// @inheritdoc IAutonomousProposal
  function emergencyTokenTransfer(
    address erc20Token,
    address to,
    uint256 amount
  ) external {
    require(
      msg.sender == AaveGovernanceV2.SHORT_EXECUTOR,
      'CALLER_NOT_EXECUTOR'
    );
    IERC20(erc20Token).safeTransfer(to, amount);
  }

  /**
   * @dev internal method to create a proposal given one executor and proposal parameters
   * @param executor address of the Short or Long executor depending on the proposal actions
   * @param ipfsHash ipfs hash of the proposal containing the description and specifications
   * @param proposalParams array of parameters that form a proposal action
   */
  function _createProposal(
    address executor,
    bytes32 ipfsHash,
    ProposalParams[] memory proposalParams
  ) internal returns (uint256) {
    require(proposalParams.length > 0, 'PROPOSAL NEEDS AT LEAST ONE ACTION');

    address[] memory targets = new address[](proposalParams.length);
    uint256[] memory values = new uint256[](proposalParams.length);
    string[] memory signatures = new string[](proposalParams.length);
    bytes[] memory calldatas = new bytes[](proposalParams.length);
    bool[] memory withDelegatecalls = new bool[](proposalParams.length);

    for (uint256 i; i < proposalParams.length; i++) {
      targets[i] = proposalParams[i].target;
      values[i] = proposalParams[i].value;
      calldatas[i] = proposalParams[i].callData;
      signatures[i] = proposalParams[i].signature;
      withDelegatecalls[i] = proposalParams[i].withDelegateCall;
    }

    return
      AaveGovernanceV2.GOV.create(
        IExecutorWithTimelock(executor),
        targets,
        values,
        signatures,
        calldatas,
        withDelegatecalls,
        ipfsHash
      );
  }
}
