// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DevOpsTools} from "@foundry-devops/DevOpsTools.sol";

contract DeployRaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;
    address PLAYER = makeAddr("player");
    uint256 STARTING_BALANCE = 10 ether;

    function setUp() external {
        // vm.prank(PLAYER);
        // vm.deal(PLAYER, STARTING_BALANCE);

        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();
    }

    function testIfRaffleDeployed() public {
        address lastestDeployedRaffle = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );

        assert(address(raffle) == lastestDeployedRaffle);
    }
}
