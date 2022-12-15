// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {GovHelpers, IAaveGovernanceV2, AaveGovernanceV2} from 'aave-helpers/GovHelpers.sol';
import {IERC20} from 'solidity-utils/contracts/oz-common/interfaces/IERC20.sol';
import {IGovernancePowerDelegationToken} from './utils/IGovernancePowerDelegationToken.sol';
import {SimpleAutonomousProposal} from '../src/contracts/SimpleAutonomousProposal.sol';
import {FEIPayload} from './utils/FEIPayload.sol';

contract feiSimpleAutonomousProposalTest is Test {
  bytes32 public constant FEI_IPFS_HASH =
    0xdb0ac263eceb481e437f455dd309d42d1313489ce25c27e39cfae9a5b513672c;

  uint256 public beforeProposalCount;

  uint256 public PROPOSAL_CREATION_TIMESTAMP;

  SimpleAutonomousProposal public feiAutonomousProposal;
  FEIPayload public feiPayload;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ethereum'), 15939210);
    beforeProposalCount = GovHelpers.GOV.getProposalsCount();

    PROPOSAL_CREATION_TIMESTAMP = block.timestamp + 1 days;

    feiPayload = new FEIPayload();
    feiAutonomousProposal = new SimpleAutonomousProposal(
      address(feiPayload),
      FEI_IPFS_HASH,
      AaveGovernanceV2.SHORT_EXECUTOR,
      PROPOSAL_CREATION_TIMESTAMP
    );
  }

  /// TEST CREATION
  function testCreateWhenAllInfoCorrect() public {
    hoax(GovHelpers.AAVE_WHALE);
    IGovernancePowerDelegationToken(GovHelpers.AAVE).delegateByType(
      address(feiAutonomousProposal),
      IGovernancePowerDelegationToken.DelegationType.PROPOSITION_POWER
    );

    vm.roll(block.number + 10);
    skip(1 days + 1);

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

  function testCreateWhenAllInfoCorrectLongExecutor() public {
    SimpleAutonomousProposal autonomous = new SimpleAutonomousProposal(
      address(feiPayload),
      FEI_IPFS_HASH,
      AaveGovernanceV2.LONG_EXECUTOR,
      block.timestamp + 10
    );

    hoax(GovHelpers.AAVE_WHALE);
    IGovernancePowerDelegationToken(GovHelpers.AAVE).delegateByType(
      address(autonomous),
      IGovernancePowerDelegationToken.DelegationType.PROPOSITION_POWER
    );

    vm.roll(block.number + 10);
    skip(1 days + 1);

    autonomous.create();

    uint256 proposalsCount = GovHelpers.GOV.getProposalsCount();
    assertEq(proposalsCount, beforeProposalCount + 1);

    IAaveGovernanceV2.ProposalWithoutVotes memory proposal = GovHelpers
      .getProposalById(proposalsCount - 1);
    assertEq(proposal.targets[0], address(feiPayload));
    assertEq(proposal.ipfsHash, FEI_IPFS_HASH);
    assertEq(address(proposal.executor), AaveGovernanceV2.LONG_EXECUTOR);
    assertEq(
      keccak256(abi.encode(proposal.signatures[0])),
      keccak256(abi.encode('execute()'))
    );
    assertEq(keccak256(proposal.calldatas[0]), keccak256(''));
  }

  function testCreateProposalTwice() public {
    hoax(GovHelpers.AAVE_WHALE);
    IGovernancePowerDelegationToken(GovHelpers.AAVE).delegateByType(
      address(feiAutonomousProposal),
      IGovernancePowerDelegationToken.DelegationType.PROPOSITION_POWER
    );

    vm.roll(block.number + 10);
    skip(1 days + 1);

    feiAutonomousProposal.create();

    vm.expectRevert(bytes('PROPOSAL_ALREADY_CREATED'));
    feiAutonomousProposal.create();
  }

  function testCreateProposalWithWrongIpfs() public {
    vm.expectRevert(bytes('PAYLOAD_IPFS_HASH_BYTES32_0'));
    new SimpleAutonomousProposal(
      address(feiPayload),
      bytes32(0),
      AaveGovernanceV2.SHORT_EXECUTOR,
      block.timestamp + 10
    );
  }

  function testCreateProposalWithWrongPayload() public {
    vm.expectRevert(bytes('PAYLOAD_ADDRESS_0'));
    new SimpleAutonomousProposal(
      address(0),
      FEI_IPFS_HASH,
      AaveGovernanceV2.SHORT_EXECUTOR,
      block.timestamp + 10
    );
  }

  function testCreateProposalWithWrongTimestamp() public {
    vm.expectRevert(bytes('CREATION_TIMESTAMP_TO_EARLY'));
    new SimpleAutonomousProposal(
      address(feiPayload),
      FEI_IPFS_HASH,
      AaveGovernanceV2.SHORT_EXECUTOR,
      0
    );
  }

  function testCreateProposalWithoutPropositionPower() public {
    SimpleAutonomousProposal autonomous = new SimpleAutonomousProposal(
      address(feiPayload),
      FEI_IPFS_HASH,
      AaveGovernanceV2.SHORT_EXECUTOR,
      block.timestamp + 10
    );
    skip(11);

    vm.expectRevert((bytes('PROPOSITION_CREATION_INVALID')));
    autonomous.create();
  }

  function testCreateInIncorrectTimestamp() public {
    SimpleAutonomousProposal autonomous = new SimpleAutonomousProposal(
      address(feiPayload),
      FEI_IPFS_HASH,
      AaveGovernanceV2.SHORT_EXECUTOR,
      block.timestamp + 10
    );

    vm.expectRevert((bytes('CREATION_TIMESTAMP_NOT_YET_REACHED')));
    autonomous.create();
  }

  function testCreateInIncorrectExecutor() public {
    vm.expectRevert((bytes('INCORRECT_EXECUTOR')));
    SimpleAutonomousProposal autonomous = new SimpleAutonomousProposal(
      address(feiPayload),
      FEI_IPFS_HASH,
      address(0),
      block.timestamp + 10
    );
  }

  function testCreateTimestampBiggerGracePeriod() public {
    uint256 time = block.timestamp + 10;
    SimpleAutonomousProposal autonomous = new SimpleAutonomousProposal(
      address(feiPayload),
      FEI_IPFS_HASH,
      AaveGovernanceV2.SHORT_EXECUTOR,
      time
    );

    skip(autonomous.GRACE_PERIOD() + 12);
    vm.expectRevert((bytes('TIMESTAMP_BIGGER_THAN_GRACE_PERIOD')));
    autonomous.create();
  }

  /// TEST VOTE
  function testVoteOnProposals() public {
    _delegateVotingPower();
    _create();

    uint256 proposalsCount = GovHelpers.GOV.getProposalsCount();

    vm.roll(block.number + AaveGovernanceV2.GOV.getVotingDelay() + 1);

    feiAutonomousProposal.vote();

    uint256 currentPower = IGovernancePowerDelegationToken(GovHelpers.AAVE)
      .getPowerCurrent(
        address(feiAutonomousProposal),
        IGovernancePowerDelegationToken.DelegationType.VOTING_POWER
      );
    IAaveGovernanceV2.ProposalWithoutVotes memory proposal = GovHelpers
      .getProposalById(proposalsCount - 1);
    assertEq(proposal.forVotes, currentPower);
  }

  function testVotingWhenProposalsNotCreated() public {
    vm.expectRevert((bytes('PROPOSAL_NOT_CREATED')));
    feiAutonomousProposal.vote();
  }

  /// TEST TOKEN RESCUE
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
    skip(1 days + 1);
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
}
