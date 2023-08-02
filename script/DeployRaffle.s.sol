// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle) {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCoordinator,
            uint64 subscriptionId,
            bytes32 gasLane,
            uint32 callbackGasLimit,
            address link
        ) = helperConfig.activeNetworkConfig();

        // checking if VRFSubscriptionID is present otherwise create one
        if (subscriptionId == 0) {
            // Create Subscription
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createVRFSubscription(
                vrfCoordinator
            );

            // Fund subscription
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundVRFSubscription(
                vrfCoordinator,
                subscriptionId,
                link
            );
        }

        // Deploy Raffle (consumer contract)
        vm.startBroadcast();
        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            vrfCoordinator,
            subscriptionId,
            gasLane,
            callbackGasLimit
        );
        vm.stopBroadcast();

        // Add the deployed contract as VRF consumer
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            vrfCoordinator,
            subscriptionId,
            address(raffle)
        );

        return raffle;
    }
}