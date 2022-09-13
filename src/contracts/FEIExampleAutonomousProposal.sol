// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveGovernanceV2, IGovernanceStrategy, AaveV2Ethereum} from 'aave-address-book/AaveAddressBook.sol';
import {IExecutorWithTimelock} from 'aave-address-book/AaveGovernanceV2.sol';
import {AutonomousProposal} from './AutonomousProposal.sol';

contract FEIExampleAutonomousProposal is AutonomousProposal {
  // Example on how to create a short executor proposal
  // referencing the same contract address
  // and handling duplicateds
  function create() external override returns (uint256) {
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

    uint256 proposalID = AaveGovernanceV2.GOV.create(
      IExecutorWithTimelock(AaveGovernanceV2.SHORT_EXECUTOR),
      targets,
      values,
      signatures,
      calldatas,
      withDelegatecalls,
      0
    );
    return proposalID;
  }

  // Providing execute() solid implementation which will be called after proposal approved
  function execute() external override {
    address FEI = 0x956F47F50A910163D8BF957Cf5846D573E7f87CA;
    AaveV2Ethereum.POOL_CONFIGURATOR.freezeReserve(FEI);
    AaveV2Ethereum.POOL_CONFIGURATOR.setReserveFactor(FEI, 20_000);
  }
}
