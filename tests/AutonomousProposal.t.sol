// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {GovHelpers, IAaveGovernanceV2, AaveGovernanceV2} from 'aave-helpers/GovHelpers.sol';
import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {IGovernancePowerDelegationToken} from './utils/IGovernancePowerDelegationToken.sol';
import {FEIExampleAutonomousProposal} from './utils/FEIExampleAutonomousProposal.sol';
import {FEIPayload} from './utils/FEIPayload.sol';

contract feiAutonomousProposalTest is Test {
  uint256 public immutable PROPOSAL_CREATION_TIMESTAMP;

  address public constant FEI = 0x956F47F50A910163D8BF957Cf5846D573E7f87CA;
  bytes32 public constant FEI_IPFS_HASH =
    0xdb0ac263eceb481e437f455dd309d42d1313489ce25c27e39cfae9a5b513672c;

  uint256 public beforeProposalCount;

  FEIExampleAutonomousProposal public feiAutonomousProposal;
  FEIPayload public feiPayload;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ethereum'), 15939210);
    beforeProposalCount = GovHelpers.GOV.getProposalsCount();

    PROPOSAL_CREATION_TIMESTAMP = block.timestamp + 1 days;

    feiPayload = new FEIPayload();
    feiAutonomousProposal = new FEIExampleAutonomousProposal(
      address(feiPayload),
      FEI_IPFS_HASH,
      PROPOSAL_CREATION_TIMESTAMP
    );
  }

  function testCreateWhenAllInfoCorrect() public {
    hoax(GovHelpers.AAVE_WHALE);
    IGovernancePowerDelegationToken(GovHelpers.AAVE).delegateByType(
      address(feiAutonomousProposal),
      IGovernancePowerDelegationToken.DelegationType.PROPOSITION_POWER
    );

    vm.roll(block.number + 10);

    feiAutonomousProposal.create();

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

  function testEmergencyTokenTransfer() public {
    hoax(GovHelpers.AAVE_WHALE);
    IERC20(GovHelpers.AAVE).transfer(address(feiAutonomousProposal), 3 ether);

    assertEq(
      IERC20(GovHelpers.AAVE).balanceOf(address(feiAutonomousProposal)),
      3 ether
    );

    address recipient = address(1230123519);

    hoax(GovHelpers.SHORT_EXECUTOR);
    feiAutonomousProposal.emergencyTokenTransfer(
      address(GovHelpers.AAVE),
      recipient,
      3 ether
    );

    assertEq(
      IERC20(GovHelpers.AAVE).balanceOf(address(feiAutonomousProposal)),
      0
    );
    assertEq(IERC20(GovHelpers.AAVE).balanceOf(address(recipient)), 3 ether);
  }

  function testEmergencyTokenTransferWhenNotShortExecutor() public {
    hoax(GovHelpers.AAVE_WHALE);
    IERC20(GovHelpers.AAVE).transfer(address(feiAutonomousProposal), 3 ether);

    assertEq(
      IERC20(GovHelpers.AAVE).balanceOf(address(feiAutonomousProposal)),
      3 ether
    );

    address recipient = address(1230123519);

    vm.expectRevert((bytes('CALLER_NOT_EXECUTOR')));
    feiAutonomousProposal.emergencyTokenTransfer(
      address(GovHelpers.AAVE),
      recipient,
      3 ether
    );
  }

  function _create() internal {
    hoax(GovHelpers.AAVE_WHALE);
    IGovernancePowerDelegationToken(GovHelpers.AAVE).delegateByType(
      address(feiAutonomousProposal),
      IGovernancePowerDelegationToken.DelegationType.PROPOSITION_POWER
    );
    vm.roll(block.number + 1);
    feiAutonomousProposal.create();
  }

  function _delegateVotingPower() internal {
    hoax(GovHelpers.AAVE_WHALE);
    IGovernancePowerDelegationToken(GovHelpers.AAVE).delegateByType(
      address(feiAutonomousProposal),
      IGovernancePowerDelegationToken.DelegationType.VOTING_POWER
    );
    vm.roll(block.number + 1);
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
