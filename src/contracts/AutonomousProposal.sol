// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {AaveGovernanceV2} from 'aave-address-book/AaveAddressBook.sol';
import {IExecutorWithTimelock} from 'aave-address-book/AaveGovernanceV2.sol';

abstract contract AutonomousProposal {
  uint256 public proposalCreatedID;

  enum ProposalExecutorType {
    LONG,
    SHORT
  }

  function create() external virtual returns(uint256);

  function execute() public virtual;

  modifier onlyOneCreation() {
    require(proposalCreatedID == 0, 'PROPOSAL_ALREADY_CREATED');
    _;
  }

  function vote() public {
    require(proposalCreatedID > 0, 'PROPOSAL_NOT_CREATED');
    AaveGovernanceV2.GOV.submitVote(proposalCreatedID, true);
  }

  function _create(ProposalExecutorType executorType, bytes32 ipfsHash)
    internal
    onlyOneCreation
    returns (uint256)
  {
    IExecutorWithTimelock executor = executorType == ProposalExecutorType.LONG
      ? IExecutorWithTimelock(AaveGovernanceV2.LONG_EXECUTOR)
      : IExecutorWithTimelock(AaveGovernanceV2.SHORT_EXECUTOR);

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

    proposalCreatedID = AaveGovernanceV2.GOV.create(
      executor,
      targets,
      values,
      signatures,
      calldatas,
      withDelegatecalls,
      ipfsHash
    );

    return proposalCreatedID;
  }
}
