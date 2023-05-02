// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Slots } from "../SlotManipulate.sol";
import { Clock } from "../Logic/Clock.sol";
import { Proxiable } from "../Proxy/Proxiable.sol";

contract ClockUUPS is Clock, Proxiable {
  // upgrade to new implementation
  function upgradeTo(address _newImpl) public {
    updateCodeAddress(_newImpl);
  }

  // upgrade to new implementation and call initialize
  function upgradeToAndCall(address _newImpl, bytes memory data) public {
    updateCodeAddress(_newImpl);
    (bool success, ) = _newImpl.delegatecall(data);
    require(success);
  }
}
