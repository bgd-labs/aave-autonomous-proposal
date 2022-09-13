// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {AaveGovernanceV2} from 'aave-address-book/AaveAddressBook.sol';
import {IExecutorWithTimelock} from 'aave-address-book/AaveGovernanceV2.sol';

abstract contract AutonomousProposal {
  bool public proposalCreated;

  function create() external virtual returns (uint256);

  function execute() external virtual;

  function createProposal() external returns (uint256) {
    require(proposalCreated == false, 'PROPOSAL_ALREADY_CREATED');
    uint256 proposalID = this.create();
    proposalCreated = true;
    return proposalID;
  }

   function createSimpleProposal(bytes32 ipfsHash) external returns (uint256) {
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
      ipfsHash
    );
    return proposalID;
  }
}
