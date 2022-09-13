// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {AaveGovernanceV2} from 'aave-address-book/AaveAddressBook.sol';
import {IExecutorWithTimelock} from 'aave-address-book/AaveGovernanceV2.sol';

abstract contract AutonomousProposal {
  bool public proposalCreated;

  function create() external virtual returns (uint256);

  function execute() external virtual;

  function createProposal() external returns (uint256) {
    require(proposalCreated == false, 'PROPOSAL_ALREADY_CREATED');
    uint256 proposalID = this.create();
    proposalCreated = true;
    return proposalID;
  }
}
