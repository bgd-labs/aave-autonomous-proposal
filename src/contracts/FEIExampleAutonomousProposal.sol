// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Ethereum} from 'aave-address-book/AaveAddressBook.sol';
import {AutonomousProposal} from './AutonomousProposal.sol';

/* @author BGD Labs
 * @dev Example of using autonomous proposal to simulate proposal 96 to change FEI risk parameters forum discussion here
 * https://app.aave.com/governance/proposal/96
 */
contract FEIExampleAutonomousProposal is AutonomousProposal {
  constructor() AutonomousProposal(ProposalExecutorType.SHORT, 0x86FB2C1C7056F55DDFEBE82B634419B2170C5CB5B981DF6A0D19523DBA959575) {}

  function execute() public override {
    address FEI = 0x956F47F50A910163D8BF957Cf5846D573E7f87CA;
    AaveV2Ethereum.POOL_CONFIGURATOR.freezeReserve(FEI);
    AaveV2Ethereum.POOL_CONFIGURATOR.setReserveFactor(FEI, 10_000);
  }
}
