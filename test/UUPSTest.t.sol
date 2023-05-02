// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { UUPSProxy } from "../src/UUPSProxy.sol";
import { ClockUUPS } from "../src/UUPSLogic/ClockUUPS.sol";
import { ClockUUPSV2 } from "../src/UUPSLogic/ClockUUPSV2.sol";
import { ClockUUPSV3 } from "../src/UUPSLogic/ClockUUPSV3.sol";

contract UUPSTest is Test {

  UUPSProxy   public uupsProxy;
  ClockUUPS   public clock;
  ClockUUPS   public clockProxy;
  ClockUUPSV2 public clockV2;
  ClockUUPSV3 public clockV3;
  ClockUUPSV3 public clockV3Proxy;
  uint256     public alarm1Time;

  address admin = makeAddr("admin");

  function setUp() public {
    clock = new ClockUUPS();
    clockV2 = new ClockUUPSV2();
    clockV3 = new ClockUUPSV3();
    vm.prank(admin);
    // initialize UUPS proxy
    uupsProxy = new UUPSProxy(
      abi.encodeWithSignature("initialize(uint256)", alarm1Time),
      address(clock)
    );
    clockProxy = ClockUUPS(address(uupsProxy));
  }

  // check Clock functionality is successfully proxied
  function testProxyWorks() public {
    assertEq(clockProxy.getTimestamp(), block.timestamp);
  }

  modifier upgradeToV3() {
    clockProxy.upgradeTo(address(clockV3));
    clockV3Proxy = ClockUUPSV3(address(uupsProxy));
    _;
  }
  // check upgradeTo works aswell
  function testUpgradeToWorks(uint256 _alarm2) public upgradeToV3 {
    clockV3Proxy.setAlarm2(_alarm2);
    assertEq(clockV3Proxy.alarm2(), _alarm2);
  }

  // check upgradeTo should fail if implementation doesn't inherit Proxiable
  function testCantUpgrade() public {
    vm.expectRevert("Not Proxiable");
    clockProxy.upgradeTo(address(clockV2));
  }

  // check upgradeTo should fail if implementation doesn't implement upgradeTo
  function testCantUpgradeIfLogicDoesntHaveUpgradeFunction() public upgradeToV3 {
    (bool success,) = address(clockV3Proxy).delegatecall(
      abi.encodeWithSignature("upgradeTo(address)", address(clock))
    );
    assertEq(success, true, "Not Upgradable");
  }
}
