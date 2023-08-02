// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract CreateSubscription is Script {
    function createVRFSubscriptionUsingConfig() public returns (uint64) {
        // getting the VRF Coordinator
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinator, , , , ) = helperConfig
            .activeNetworkConfig();

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

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            uint64 subId,
            ,
            ,
            address link
        ) = helperConfig.activeNetworkConfig();

        // fund
        fundVRFSubscription(vrfCoordinator, subId, link);
    }

    function fundVRFSubscription(
        address vrfCoordinator,
        uint64 subId,
        address link
    ) public {
        console.log("Funding subscription: ", subId);
        console.log("Using VRF Coordinator: ", vrfCoordinator);
        console.log("On chain id: ", block.chainid);

        if (block.chainid == 31337) {
            // fund using VRFCoordinatorV2Mock
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(
                subId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            // fund using LinkToken Mock
            vm.startBroadcast();
            LinkToken(link).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}
