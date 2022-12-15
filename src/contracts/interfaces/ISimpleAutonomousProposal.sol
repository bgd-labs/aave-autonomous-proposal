// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAutonomousProposal} from './IAutonomousProposal.sol';

interface ISimpleAutonomousProposal {
  /// @dev returns the address of the proposal payload
  function PAYLOAD() external returns (address);

  /// @dev returns the ipfs hash of the proposal description and specification
  function IPFS_HASH() external returns (bytes32);

  /// @dev returns the address of the executor of the payload. Must be either Short or Long governance executor
  function EXECUTOR() external returns (address);

  /// @dev returns the id of the created proposal
  function getProposalId() external view returns (uint256);

  /// @dev returns if the proposal has been created
  function isProposalCreated() external view returns (bool);

  /// @dev returns the object containing the proposal parameters
  function getProposalParams()
    external
    view
    returns (IAutonomousProposal.ProposalParams memory);
}
