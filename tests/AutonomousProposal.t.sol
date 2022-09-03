// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveGovernanceV2, IAaveGovernanceV2} from 'aave-address-book/AAVEGovernanceV2.sol';
import {GovHelpers, IAaveGov} from 'aave-helpers/GovHelpers.sol';
import 'forge-std/console.sol';
import 'forge-std/Test.sol';

import {AutonomousProposal} from '../src/contracts/AutonomousProposal.sol';

interface DelegateContract {
  function delegate(address delegatee) external;
  function delegateByType(address delegatee, uint8 delegationType) external;
}

contract AutonomousProposalTest is Test {
  event ProposalExecuted(uint256 indexed proposalID);
  event ProposalCreated(uint256 proposalID);

  AutonomousProposal public proposalPayload;
  DelegateContract public delegateContract;
  uint256 proposalID;

  address internal constant AAVE_WHALE =
        0x25F2226B597E8F9514B3F68F00f494cF4f286491;

  address internal constant DELEGATE = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;

  function setUp() public {
    proposalPayload = new AutonomousProposal();
    delegateContract = DelegateContract(DELEGATE);
  }

  function testEmptyPropositionPower() public {
    assertEq(proposalPayload.getPropositionPower(), 0);
  }

  function testPropositionPowerDelegate() public {
    _testCreateProposal();
    _testProposalCreatedProperly();
    _testProposalExecution();
  }

  function _testCreateProposal() public {
    vm.startPrank(AAVE_WHALE);
    delegateContract.delegateByType(address(proposalPayload), 1);
    vm.stopPrank();
    vm.roll(block.number + 1);
    proposalID = proposalPayload.create();
    assertTrue(proposalID > 0, 'Proposal was not created');
  }

  function _testProposalCreatedProperly() public {
    IAaveGovernanceV2.ProposalWithoutVotes memory createdProposal =  AaveGovernanceV2.GOV.getProposalById(proposalID);
    proposalID = createdProposal.id;
    assertEq(createdProposal.creator, address(proposalPayload));
  }

  function _testProposalExecution() public {
    vm.expectEmit(true, false, false, false);
    emit ProposalExecuted(proposalID);
    GovHelpers.passVoteAndExecute(vm, proposalID);
  }
}
