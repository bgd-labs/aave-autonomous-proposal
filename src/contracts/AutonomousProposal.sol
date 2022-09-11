// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract AutonomousProposal {
  function create() external virtual returns (uint256);
  function execute() external virtual;
}
