// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {AaveGovernanceV2, IAaveGovernanceV2} from 'aave-address-book/AAVEGovernanceV2.sol';
import {AaveV2Ethereum} from 'aave-address-book/AaveAddressBook.sol';
import {GovHelpers, IAaveGov} from 'aave-helpers/GovHelpers.sol';

import {FEIExampleAutonomousProposal} from './utils/FEIExampleAutonomousProposal.sol';
import {FEIPayload} from './utils/FEIPayload.sol';

contract AutonomousProposalTest is Test {
  address public FEI = 0x956F47F50A910163D8BF957Cf5846D573E7f87CA;
  bytes32 public constant FEI_IPFS_HASH =
    0xdb0ac263eceb481e437f455dd309d42d1313489ce25c27e39cfae9a5b513672c;
  uint256 public constant PROPOSAL_CREATION_TIMESTAMP =
    block.timestamp + 1 days;

  uint256 public beforeProposalCount;

  FEIExampleAutonomousProposal public feiAutonomousProposal;
  FEIPayload public feiPayload;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ethereum'), 15939210);
    beforeProposalCount = GovHelpers.GOV.getProposalsCount();

    feiPayload = new FEIPayload();
    feiAutonomousProposal = new FEIExampleAutonomousProposal(
      address(feiPayload),
      FEI_IPFS_HASH,
      PROPOSAL_CREATION_TIMESTAMP
    );
  }

  function testCreateProposalsWhenAllInfoCorrect() public {
    hoax(GovHelpers.AAVE_WHALE);
    IGovernancePowerDelegationToken(GovHelpers.AAVE).delegateByType(
      address(feiAutonomousProposal),
      IGovernancePowerDelegationToken.DelegationType.PROPOSITION_POWER
    );

    vm.roll(block.number + 10);

    autonomousProposal.create();

    uint256 proposalsCount = GovHelpers.GOV.getProposalsCount();
    assertEq(proposalsCount, beforeProposalCount + 1);

    IAaveGovernanceV2.ProposalWithoutVotes memory proposal = GovHelpers
      .getProposalById(proposalsCount - 1);
    assertEq(proposal.targets[0], address(feiPayload));
    assertEq(proposal.ipfsHash, FEI_IPFS_HASH);
    assertEq(address(proposal.executor), AaveGovernanceV2.SHORT_EXECUTOR);
    assertEq(
      keccak256(abi.encode(proposal.signatures[0])),
      keccak256(abi.encode('execute()'))
    );
    assertEq(keccak256(proposal.calldatas[0]), keccak256(''));
  }

  //  function testCreateProposalWithoutPower() public {
  //    vm.expectRevert('PROPOSITION_CREATION_INVALID');
  //    proposalPayload.createProposal();
  //  }
  //
  //  function testPropositionPowerDelegate() public {
  //    _testCreateProposal();
  //    _testProposalCreatedProperly();
  //    _testProposalExecution();
  //    _testProposalCreatedOnlyOnceFail();
  //  }
  //
  //  function _testCreateProposal() public {
  //    vm.startPrank(AAVE_WHALE);
  //    delegateContract.delegateByType(address(proposalPayload), 1);
  //    vm.stopPrank();
  //    vm.roll(block.number + 1);
  //    proposalID = proposalPayload.createProposal();
  //  }
  //
  //  function _testProposalCreatedProperly() public {
  //    assertTrue(proposalID > 0, 'Proposal was not created');
  //
  //    IAaveGovernanceV2.ProposalWithoutVotes
  //      memory createdProposal = AaveGovernanceV2.GOV.getProposalById(proposalID);
  //    proposalID = createdProposal.id;
  //
  //    assertEq(createdProposal.creator, address(proposalPayload));
  //  }
  //
  //  function _testProposalExecution() public {
  //    (, , , , uint256 reserveFactor, , , , , ) = AaveV2Ethereum
  //      .AAVE_PROTOCOL_DATA_PROVIDER
  //      .getReserveConfigurationData(FEI);
  //    assertEq(reserveFactor, 10_000);
  //
  //    GovHelpers.passVoteAndExecute(vm, proposalID);
  //
  //    (, , , , uint256 newReserveFactor, , , , , ) = AaveV2Ethereum
  //      .AAVE_PROTOCOL_DATA_PROVIDER
  //      .getReserveConfigurationData(FEI);
  //    assertEq(newReserveFactor, 20_000);
  //  }
  //
  //  function _testProposalCreatedOnlyOnceFail() public {
  //    vm.startPrank(AAVE_WHALE);
  //    delegateContract.delegateByType(address(proposalPayload), 1);
  //    vm.stopPrank();
  //    vm.roll(block.number + 1);
  //    vm.expectRevert(bytes('PROPOSAL_ALREADY_CREATED'));
  //    proposalID = proposalPayload.createProposal();
  //  }
}
