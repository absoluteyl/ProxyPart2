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
  bytes32 constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1);

  constructor(address _implementation) {
    _setSlotToAddress(IMPLEMENTATION_SLOT, _implementation);
  }

  fallback() external payable virtual {
    _delegate(_getSlotToAddress(IMPLEMENTATION_SLOT));
  }

  receive() external payable {}

  modifier checkImpAddress(address _addr) {
    require(_addr != address(0), "Cannot set implementation to address(0)");
    require(_addr != _getSlotToAddress(IMPLEMENTATION_SLOT), "Cannot set implementation to the same address");
    _;
  }

  function upgradeTo(address _newImpl) public virtual checkImpAddress(_newImpl) {
    _setSlotToAddress(IMPLEMENTATION_SLOT, _newImpl);
  }

  function upgradeToAndCall(address _newImpl, bytes memory data) public virtual checkImpAddress(_newImpl) {
    _setSlotToAddress(IMPLEMENTATION_SLOT, _newImpl);
    (bool success, ) = _newImpl.delegatecall(data);
    require(success);
  }
}
