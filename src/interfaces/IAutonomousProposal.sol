// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAutonomousProposal {
  function create() external returns (uint256);
  function execute() external;
}
