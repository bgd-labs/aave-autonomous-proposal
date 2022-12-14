// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AaveV2Ethereum} from 'aave-address-book/AaveAddressBook.sol';

contract FEIPayload {
  address public constant FEI = 0x956F47F50A910163D8BF957Cf5846D573E7f87CA;

  function execute() external override {
    AaveV2Ethereum.POOL_CONFIGURATOR.freezeReserve(FEI);
  }
}
