// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveGovernanceV2} from 'aave-address-book/AaveAddressBook.sol';
import {IExecutorWithTimelock} from 'aave-address-book/AaveGovernanceV2.sol';

 /* @author BGD Labs
 * @dev Aave proposition power aggregator contract, with helper methods to create fully autonomous proposal referencing it's own address
 * - Create proposal once per deployment.
 * - Vote on created proposal in case accidental voting power was delegated with proposition power
 */
abstract contract AutonomousProposal {
  uint256 public _proposalCreatedID;

  IExecutorWithTimelock public immutable executor;
  bytes32 public immutable ipfsHash;

  enum ProposalExecutorType {
    LONG,
    SHORT
  }

  constructor(ProposalExecutorType _executorType, bytes32 _ipfsHash) {
    executor = _executorType == ProposalExecutorType.LONG
      ? IExecutorWithTimelock(AaveGovernanceV2.LONG_EXECUTOR)
      : IExecutorWithTimelock(AaveGovernanceV2.SHORT_EXECUTOR);
    ipfsHash = _ipfsHash;
  }

  function vote() public {
    require(_proposalCreatedID > 0, 'PROPOSAL_NOT_CREATED');
    AaveGovernanceV2.GOV.submitVote(_proposalCreatedID, true);
  }

  function create() external returns (uint256) {
    require(_proposalCreatedID == 0, 'PROPOSAL_ALREADY_CREATED');

    address[] memory targets = new address[](1);
    targets[0] = address(this);
    uint256[] memory values = new uint256[](1);
    values[0] = 0;
    string[] memory signatures = new string[](1);
    signatures[0] = 'execute()';
    bytes[] memory calldatas = new bytes[](1);
    calldatas[0] = '';

    bool[] memory withDelegatecalls = new bool[](1);
    withDelegatecalls[0] = true;

    return
      _proposalCreatedID = AaveGovernanceV2.GOV.create(
        executor,
        targets,
        values,
        signatures,
        calldatas,
        withDelegatecalls,
        ipfsHash
      );
  }

  function getProposalCreatedId() external view returns (uint256) {
    return _proposalCreatedID;
  }

  function execute() public virtual;
}
