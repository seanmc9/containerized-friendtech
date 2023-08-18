// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ContainerizedFriendtech} from "../src/ContainerizedFriendtech.sol";

contract ContainerizedFriendtechTest is Test {
    address public constant PROTOCOL_FEE_DESTINATION = 0xd698e31229aB86334924ed9DFfd096a71C686900;
    uint256 public constant PROTOCOL_FEE_PERCENT = 100000;
    uint256 public constant SUBJECT_FEE_PERCENT = 100000;

    ContainerizedFriendtech public containerizedFriendtech;

    function setUp() public {
        containerizedFriendtech = new ContainerizedFriendtech(PROTOCOL_FEE_DESTINATION, PROTOCOL_FEE_PERCENT, SUBJECT_FEE_PERCENT);
    }

    function testProtocolFeeDestination() public {
        assertEq(containerizedFriendtech.protocolFeeDestination(), PROTOCOL_FEE_DESTINATION);
    }
}
