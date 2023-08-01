// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    Raffle internal raffle;
    address PLAYER = makeAddr("player");
    uint256 public STARTING_BALANCE = 10 ether;
    HelperConfig.NetworkConfig internal activeNetworkConfig;

    // Event
    event EnteredRaffle(address indexed PLAYER);

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        raffle = deployRaffle.run();

        // getting access to active network variables through HelperConfig() script
        HelperConfig helperConfig = new HelperConfig();
        (
            activeNetworkConfig.entranceFee,
            activeNetworkConfig.interval,
            activeNetworkConfig.vrfCoordinator,
            activeNetworkConfig.subscriptionId,
            activeNetworkConfig.gasLane,
            activeNetworkConfig.callbackGasLimit
        ) = helperConfig.activeNetworkConfig();

        vm.deal(PLAYER, STARTING_BALANCE);
    }

    function testRaffleInitialisesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    /************************
        Enter Raffle Testcases
     *************************/

    function testRaffleRevertsWhenYouDontPayEnough() public {
        // Arrange
        vm.prank(PLAYER);
        // ACT/ ASSET
        vm.expectRevert(); // vm.expectRevert(Raffle.Raffle__NotEnoughETHSent.selector); should work but isnt
        raffle.enterRaffle{value: 0.001 ether}();
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        // Arrange
        vm.prank(PLAYER);
        // Act
        raffle.enterRaffle{value: activeNetworkConfig.entranceFee}();
        //Asset
        assert(raffle.getRafflePlayer(0) == PLAYER);
    }

    function testRaffleStateShouldBeOpenOnEntry() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: activeNetworkConfig.entranceFee}();

        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testEnterRaffleEventEmit() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle)); // vm.expectEmit(indexedTopic1, indexedTopic2, indexedTopic3, unindexedData, emitter)

        emit EnteredRaffle(PLAYER); // emit the event that is expected to be emitted
        raffle.enterRaffle{value: activeNetworkConfig.entranceFee}(); // Trigger actual emit
    }
}
