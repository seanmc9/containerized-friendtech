// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ContainerizedFriendtech} from "../src/ContainerizedFriendtech.sol";

contract ContainerizedFriendtechTest is Test {
    ContainerizedFriendtech public containerizedFriendtech;

    function setUp() public {
        containerizedFriendtech = new ContainerizedFriendtech();
    }
}
