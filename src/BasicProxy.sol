// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Proxy } from "./Proxy/Proxy.sol";
import { Slots } from "./SlotManipulate.sol";

// Hands-on: https://docs.google.com/presentation/d/1lFveL2KWquktUjI7asbuedwy19tPBw66sxG8XxUOlJo/edit#slide=id.g21ea8db5214_7_48
// 請根據 ERC1967 標準實作：
// 請將 BasicProxy 改寫，將 Logic contract 存在bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1) 這個 Slot
// 改寫 upgradeTo 和 upgradeToAndCall 的邏輯
// 同樣使用 Clock 和 ClockV2 來測試 Upgrade 是否成功
contract BasicProxy is Proxy, Slots {

  constructor(address _implementation) {
  }

  fallback() external payable virtual {
  }

  receive() external payable {}

  function upgradeTo(address _newImpl) public virtual {
  }

  function upgradeToAndCall(address _newImpl, bytes memory data) public virtual {
  }
}