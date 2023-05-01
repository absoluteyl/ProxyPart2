// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { Transparent } from "../src/Transparent.sol";
import { Clock } from "../src/Logic/Clock.sol";
import { ClockV2 } from "../src/Logic/ClockV2.sol";

contract TransparentTest is Test {

  Transparent public transparentProxy;
  Clock       public clock;
  Clock       public clockProxy;
  ClockV2     public clockV2;
  ClockV2     public clockV2Proxy;

  address admin = makeAddr("admin");
  address user1 = makeAddr("user1");

  function setUp() public {
    clock = new Clock();
    clockV2 = new ClockV2();
    vm.prank(admin);
    transparentProxy = new Transparent(address(clock));
    clockProxy = Clock(address(transparentProxy));
  }

  modifier initClockProxy(uint256 _alarm1) {
    clockProxy.initialize(_alarm1);
    _;
  }
  // check Clock functionality is successfully proxied
  function testProxyWorks(uint256 _alarm1) public initClockProxy(_alarm1) {
    assertEq(clockProxy.getTimestamp(), block.timestamp);
  }

  // check upgradeTo could be called only by admin
  function testUpgradeToOnlyAdmin(uint256 _alarm1, uint256 _alarm2) public
    initClockProxy(_alarm1)
  {
    vm.expectRevert("only admin");
    transparentProxy.upgradeTo(address(clockV2));

    vm.prank(admin);
    transparentProxy.upgradeTo(address(clockV2));
    clockV2Proxy = ClockV2(address(transparentProxy));
    clockV2Proxy.setAlarm2(_alarm2);
    assertEq(clockV2Proxy.getTimestamp(), block.timestamp);
    assertEq(clockV2Proxy.alarm2(), _alarm2);
  }

  // check upgradeToAndCall could be called only by admin
  function testUpgradeToAndCallOnlyAdmin(uint256 _alarm1, uint256 _alarm2) public
    initClockProxy(_alarm1)
  {
    vm.expectRevert("only admin");
    transparentProxy.upgradeToAndCall(
      address(clockV2),
      abi.encodeWithSignature("setAlarm2(uint256)", _alarm2)
    );

    vm.prank(admin);
    transparentProxy.upgradeToAndCall(
      address(clockV2),
      abi.encodeWithSignature("setAlarm2(uint256)", _alarm2)
    );
    clockV2Proxy = ClockV2(address(transparentProxy));
    clockV2Proxy.setAlarm2(_alarm2);
    assertEq(clockV2Proxy.getTimestamp(), block.timestamp);
    assertEq(clockV2Proxy.alarm2(), _alarm2);
  }

  // check admin shouldn't trigger fallback
  function testFallbackShouldRevertIfSenderIsAdmin(uint256 _alarm1) public
    initClockProxy(_alarm1)
  {
    vm.prank(admin);
    vm.expectRevert("not an admin function");
    clockProxy.setAlarm1(_alarm1);
  }

  // check admin shouldn't trigger fallback
  function testFallbackShouldSuccessIfSenderIsntAdmin(uint256 _alarm1) public
    initClockProxy(_alarm1)
  {
    clockProxy.setAlarm1(_alarm1);
    assertEq(clockProxy.alarm1(), _alarm1);
  }
}
