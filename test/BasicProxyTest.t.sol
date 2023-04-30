// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { Clock } from "../src/Logic/Clock.sol";
import { ClockV2 } from "../src/Logic/ClockV2.sol";
import { BasicProxy } from "../src/BasicProxy.sol";

contract BasicProxyTest is Test {

  BasicProxy public basicProxy;
  Clock      public clock;
  Clock      public clockProxy;
  ClockV2    public clockV2;
  ClockV2    public clockV2Proxy;
  uint256    public alarm1Time = block.timestamp + 60;
  uint256    public alarm2Time = block.timestamp + 123;

  function setUp() public {
    clock   = new Clock();
    clockV2 = new ClockV2();
    basicProxy = new BasicProxy(address(clock));
    clockProxy = Clock(address(basicProxy));
  }

  // check Clock functionality is successfully proxied
  function testProxyWorks() public {
    assertEq(clockProxy.getTimestamp(), block.timestamp);
  }

  modifier initClockProxy(uint256 _alarm1Time) {
    clockProxy.initialize(_alarm1Time);
    _;
  }
  // check initialize works for only once
  function testInitialize() public initClockProxy(alarm1Time) {
    vm.expectRevert("Already initialized");
    clockProxy.initialize(alarm1Time);
  }

  // check Clock functionality is successfully proxied
  function testClockProxy() public initClockProxy(alarm1Time) {
    // alarm1 should be set on proxy contract instead of logic contract
    assertEq(clock.alarm1(), 0);
    assertEq(clockProxy.alarm1(), alarm1Time);
    // can set alarm1 on proxy contract
    clockProxy.setAlarm1(alarm2Time);
    assertEq(clockProxy.alarm1(), alarm2Time);
  }

  modifier upgradeToV2() {
    basicProxy.upgradeTo(address(clockV2));
    clockV2Proxy = ClockV2(address(basicProxy));
    _;
  }
  // upgrade Logic contract to ClockV2
  function testUpgrade() public
    initClockProxy(alarm1Time)
    upgradeToV2
  {
    // check proxy state stays the same
    vm.expectRevert("Already initialized");
    clockV2Proxy.initialize(alarm1Time);
    assertEq(clockV2Proxy.alarm1(), alarm1Time, "timestamp should be equal to alarm1Time");

    // check new functionality is available
    clockV2Proxy.setAlarm2(alarm2Time);
    assertEq(clockV2Proxy.alarm2(), alarm2Time, "timestamp should be equal to alarm2Time");
  }

  function testUpgradeAndCall() public initClockProxy(alarm1Time) {
    // calling setAlarm2 right after upgrade
    basicProxy.upgradeToAndCall(
      address(clockV2),
      abi.encodeWithSignature("setAlarm2(uint256)", alarm2Time)
    );
    clockV2Proxy = ClockV2(address(basicProxy));

    // check state had been changed according to setAlarm2
    assertEq(clockV2Proxy.alarm2(), alarm2Time);
  }

  function testChangeOwnerWontCollision() public
    initClockProxy(alarm1Time)
    upgradeToV2
  {
    // call changeOwner to update owner
    address owner = makeAddr("owner");
    clockV2Proxy.changeOwner(owner);
    // check Clock functionality is successfully proxied
    assertEq(clockV2Proxy.owner(), owner);
  }
}
