// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/console.sol';
import {Script} from 'forge-std/Script.sol';
import {FEIExampleAutonomousProposal} from '../src/contracts/FEIExampleAutonomousProposal.sol';

contract DeployAvaFRAXSteward is Script {
    function run() external {
        vm.startBroadcast();
        new FEIExampleAutonomousProposal();
        vm.stopBroadcast();
    }
}
