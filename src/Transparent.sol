// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Slots } from "./SlotManipulate.sol";
import { BasicProxy } from "./BasicProxy.sol";

contract Transparent is Slots, BasicProxy {
  bytes32 constant ADMIN_SLOT = bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1);

  constructor(address _implementation) BasicProxy(_implementation) {
    // set admin address to Admin slot
    _setSlotToAddress(ADMIN_SLOT, msg.sender);
    _setSlotToAddress(IMPLEMENTATION_SLOT, _implementation);
  }

  modifier onlyAdmin {
    require(msg.sender == _getSlotToAddress(ADMIN_SLOT), "only admin");
    _;
  }

  function upgradeTo(address _newImpl) public override onlyAdmin {
    super.upgradeTo(_newImpl);
  }

  function upgradeToAndCall(address _newImpl, bytes memory data) public override onlyAdmin {
    super.upgradeToAndCall(_newImpl, data);
  }

  fallback() external payable override{
    require(msg.sender != _getSlotToAddress(ADMIN_SLOT), "not an admin function");
    _delegate(_getSlotToAddress(IMPLEMENTATION_SLOT));
  }
}
