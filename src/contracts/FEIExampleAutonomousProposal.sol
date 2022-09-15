// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Ethereum} from 'aave-address-book/AaveAddressBook.sol';
import {AutonomousProposal} from './AutonomousProposal.sol';

/* @author BGD Labs
 * @dev Example of using autonomous proposal to change FEI risk parameters
 */
contract FEIExampleAutonomousProposal is AutonomousProposal {
  constructor() AutonomousProposal(ProposalExecutorType.SHORT, 0x1d008d832f4a2aef5eb81bf1ff8becbd6bc67e6405ec3921b984569389852b66) {}

  function execute() public override {
    address FEI = 0x956F47F50A910163D8BF957Cf5846D573E7f87CA;
    AaveV2Ethereum.POOL_CONFIGURATOR.freezeReserve(FEI);
    AaveV2Ethereum.POOL_CONFIGURATOR.setReserveFactor(FEI, 20_000);
  }
}
