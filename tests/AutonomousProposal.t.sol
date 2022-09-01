// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import 'forge-std/console.sol';

import {AutonomousProposal} from '../src/contracts/AutonomousProposal.sol';

interface DelegateContract {
  function delegate(address delegatee) external;
}

contract AutonomousProposalTest is Test {
  AutonomousProposal public proposal;
  DelegateContract public delegate;

  address internal constant AAVE_WHALE =
        0x25F2226B597E8F9514B3F68F00f494cF4f286491;

  address internal constant DELEGATE = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;

  function setUp() public {
    proposal = new AutonomousProposal();
    delegate = DelegateContract(DELEGATE);
  }

  function testEmptyPropositionPower() public {
    assertEq(proposal.getPropositionPower(), 0);
  }

  function testPropositionPowerDelegate() public {
    vm.startPrank(AAVE_WHALE);
    delegate.delegate(address(proposal));
    vm.stopPrank();
    vm.roll(block.number + 1);
    uint256 proposalId = proposal.create();
    assertTrue(proposalId > 0, 'Proposal was not created');
  }
}
