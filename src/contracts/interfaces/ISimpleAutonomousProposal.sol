// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAutonomousProposal {
  function PAYLOAD() external returns (address);

  function IPFS_HASH() external returns (bytes32);

  function EXECUTOR() external returns (address);

  function getProposalId() external view returns (uint256);

  function isProposalCreated() external view returns (bool);
}
