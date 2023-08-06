// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract DeployRaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;
    uint256 public subscriptionId;

    function setUp() public {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();

        (, , , subscriptionId, , , , ) = helperConfig.activeNetworkConfig();
    }

    function testContractDeployed() public view {
        assert(address(raffle) != address(0));
    }
}
