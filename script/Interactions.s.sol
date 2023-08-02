// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract CreateSubscription is Script {
    function createVRFSubscriptionUsingConfig() public returns (uint64) {
        // getting the VRF Coordinator
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinator, , , ) = helperConfig.activeNetworkConfig();

        return createVRFSubscription(vrfCoordinator);
    }

    function createVRFSubscription(
        address vrfCoordinator
    ) public returns (uint64) {
        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        console.log("Your VRF subId is:", subId);
        console.log("Dont forget to add your VRF subId to HelperConfig.s.sol");
        return subId;
    }

    function run() external returns (uint64) {
        return createVRFSubscriptionUsingConfig();
    }
}
