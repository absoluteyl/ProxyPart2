// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

// Hands-on: https://docs.google.com/presentation/d/1lFveL2KWquktUjI7asbuedwy19tPBw66sxG8XxUOlJo/edit#slide=id.g21ea8db5214_7_38
contract Slots {

  function _setSlotToUint256(bytes32 _slot, uint256 value) internal {
    assembly {
      sstore(_slot, value)
    }
  }

  function _setSlotToAddress(bytes32 _slot, address value) internal {
    assembly {
      sstore(_slot, value)
    }
  }

  function _getSlotToAddress(bytes32 _slot) internal view returns (address value) {
    assembly {
      value := sload(_slot)
    }
  }
}

contract SlotManipulate is Slots {

  // 在 keccak256(“appworks.week8”) 這個 slot 中存入 2023_4_27
  function setAppworksWeek8(uint256 amount) external {
    // TODO: set AppworksWeek8
    _setSlotToUint256(keccak256("appworks.week8"), amount);
  }

  // 在 bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1) 中存入隨意地址
  function setProxyImplementation(address _implementation) external {
    // TODO: set Proxy Implenmentation address
    _setSlotToAddress(
      bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1),
      _implementation
    );
  }

  // 在 bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1) 中存入隨意地址
  function setBeaconImplementation(address _implementation) external {
    // TODO: set Beacon Implenmentation address
    _setSlotToAddress(
      bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1),
      _implementation
    );
  }

  // 在 bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1) 中存入隨意地址
  function setAdminImplementation(address _who) external {
    // TODO: set Admin Implenmentation address
    _setSlotToAddress(
      bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1),
      _who
    );
  }

  // 在 keccak256("PROXIABLE") 中存入隨意地址 - UUPS convention
  function setProxiable(address _implementation) external {
    // TODO: set Proxiable Implenmentation address
    _setSlotToAddress(
      keccak256("PROXIABLE"), _implementation
    );
  }
}
