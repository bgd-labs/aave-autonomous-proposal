// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveGovernanceV2, IGovernanceStrategy} from 'aave-address-book/AaveAddressBook.sol';
import {IExecutorWithTimelock} from 'aave-address-book/AaveGovernanceV2.sol';

contract AutonomousProposal {
  event ProposalCreated(uint256 proposalID);
  event ProposalExecuted(uint256 indexed proposalID);

  uint256 private proposalID;

  function getPropositionPower() external view returns (uint256) {
    IGovernanceStrategy strategy = IGovernanceStrategy(
      AaveGovernanceV2.GOV.getGovernanceStrategy()
    );
    return strategy.getPropositionPowerAt(address(this), block.number);
  }

  function create() public returns (uint256) {
    uint256 propositionPower = this.getPropositionPower();
    require(propositionPower > 80_000, 'Not enough proposition power');

    // preparing proposal creation
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

    proposalID = AaveGovernanceV2.GOV.create(
      IExecutorWithTimelock(AaveGovernanceV2.SHORT_EXECUTOR),
      targets,
      values,
      signatures,
      calldatas,
      withDelegatecalls,
      0
    );
    emit ProposalCreated(proposalID);
    return proposalID;
  }

  function execute() public {
    emit ProposalExecuted(proposalID);
  }
}
