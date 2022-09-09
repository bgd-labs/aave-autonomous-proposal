// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveGovernanceV2, IGovernanceStrategy, AaveV2Ethereum} from 'aave-address-book/AaveAddressBook.sol';
import {IExecutorWithTimelock} from 'aave-address-book/AaveGovernanceV2.sol';
import 'forge-std/console.sol';

abstract contract AutonomousProposal {
  event ProposalCreated(uint256 proposalID);
  bool private proposalCreated = false;

  function getPropositionPower() external view returns (uint256) {
    IGovernanceStrategy strategy = IGovernanceStrategy(
      AaveGovernanceV2.GOV.getGovernanceStrategy()
    );
    return strategy.getPropositionPowerAt(address(this), block.number);
  }

  function create() public returns (uint256) {
    require(proposalCreated == false, 'Already created');
    uint256 propositionPower = this.getPropositionPower();
    require(propositionPower > 80_000 ether, 'Not enough proposition power');

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


    uint256 executingProposalID = AaveGovernanceV2.GOV.create(
      IExecutorWithTimelock(AaveGovernanceV2.SHORT_EXECUTOR),
      targets,
      values,
      signatures,
      calldatas,
      withDelegatecalls,
      0
    );
    emit ProposalCreated(executingProposalID);
    proposalCreated = true;
    return executingProposalID;
  }

   function execute() virtual external;
}
