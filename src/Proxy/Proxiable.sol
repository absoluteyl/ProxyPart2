// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract Proxiable {

  function proxiableUUID() public pure returns (bytes32) {
    bytes32 _slot = keccak256("PROXIABLE");
    // 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7
    return _slot;
  }

  function updateCodeAddress(address newAddress) internal {
    // check if target address has proxiableUUID
    (bool success,) = newAddress.delegatecall(abi.encodeWithSignature("proxiableUUID()"));
    require(success, "Not Proxiable");
    // update code address
    bytes32 proxiableSlot= proxiableUUID();
    assembly {
      sstore(proxiableSlot, newAddress)
    }
  }
}
