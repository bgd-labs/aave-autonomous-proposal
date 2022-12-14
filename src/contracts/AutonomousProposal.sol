// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveGovernanceV2, IExecutorWithTimelock, IGovernanceStrategy} from 'aave-address-book/AaveGovernanceV2.sol';
import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {SafeERC20} from 'solidity-utils/contracts/oz-common/SafeERC20.sol';
import {IAutonomousProposal} from './interfaces/IAutonomousProposal.sol';

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
  function create() external virtual inCreationWindow;

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
    ProposalParams[] proposalParams
  ) internal returns (uint256) {
    uint256 paramsLength = params.length;
    require(paramsLength > 0, 'PROPOSAL NEEDS AT LEAST ONE ACTION');

    address[] memory targets = new address[](paramsLength);
    uint256[] memory values = new uint256[](paramsLength);
    string[] memory signatures = new string[](paramsLength);
    bytes[] memory calldatas = new bytes[](paramsLength);
    bool[] memory withDelegatecalls = new bool[](paramsLength);

    for (uint256 i; i < paramsLength; i++) {
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
