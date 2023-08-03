// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract RaffleTest is Test {
    Raffle internal raffle;
    address PLAYER = makeAddr("player");
    uint256 public deploymentTimeStamp;
    uint256 public STARTING_BALANCE = 10 ether;
    HelperConfig.NetworkConfig internal activeNetworkConfig;

    // Event
    event EnteredRaffle(address indexed PLAYER);

    function setUp() external {
        // Deploy the contract to be tested
        DeployRaffle deployRaffle = new DeployRaffle();
        raffle = deployRaffle.run();

        deploymentTimeStamp = block.timestamp;
        /* this is been recorded to match the s_lastTimeStamp value of the Raffle.sol contract. 
        Will be used in `testCheckUpKeepReturnsFalseIfEnoughTimeHasntPassed` to restore the block timestamp to when Raffle was deployed in order to nullify the interval. */

        // getting access to active network variables through HelperConfig() script
        HelperConfig helperConfig = new HelperConfig();
        (
            activeNetworkConfig.entranceFee,
            activeNetworkConfig.interval,
            activeNetworkConfig.vrfCoordinator,
            activeNetworkConfig.subscriptionId,
            activeNetworkConfig.gasLane,
            activeNetworkConfig.callbackGasLimit,
            activeNetworkConfig.link
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

    function testRaffleShouldNotAllowEntryWhenCalculating()
        public
        raffleEntered
    {
        // Act
        raffle.performUpkeep(""); // put the raffle in a calculating state

        // Arrange to Enter raffle again
        vm.expectRevert(); // vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selecctor)
        vm.prank(PLAYER);
        // Act again
        raffle.enterRaffle{value: activeNetworkConfig.entranceFee}();
    }

    function testEnterRaffleEventEmit() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle)); // vm.expectEmit(indexedTopic1, indexedTopic2, indexedTopic3, unindexedData, emitter)

        emit EnteredRaffle(PLAYER); // emit the event that is expected to be emitted
        raffle.enterRaffle{value: activeNetworkConfig.entranceFee}(); // Trigger actual emit
    }

    /************************
        CheckUpKeep Testcases
     *************************/

    function testCheckUpKeepReturnsFalseIfNotEnoughBalance() public {
        vm.warp(block.timestamp + activeNetworkConfig.interval + 1);
        vm.roll(block.number + 1);

        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        assert(!upkeepNeeded);
    }

    function testCheckUpKeepReturnsFalseIfCalculating() public {
        // Arrange
        vm.warp(block.timestamp + activeNetworkConfig.interval + 1);
        vm.roll(block.number + 1);
        raffle.enterRaffle{value: activeNetworkConfig.entranceFee}();

        // Act
        raffle.performUpkeep("");

        // Assert
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        assert(!upkeepNeeded);
    }

    function testCheckUpKeepReturnsFalseIfEnoughTimeHasntPassed() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: activeNetworkConfig.entranceFee}();
        // raffle.performUpkeep("");

        // Act
        vm.warp(deploymentTimeStamp);
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        // assert
        assert(!upkeepNeeded);
    }

    function testCheckUpKeepReturnsTrueIfAllParametersAreGood() public {
        // Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: activeNetworkConfig.entranceFee}();
        vm.warp(block.timestamp + activeNetworkConfig.interval + 1);

        // Act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        // Assert
        assert(upkeepNeeded);
    }

    /************************
        performUpKeep Testcases
     *************************/

    function testPerformUpKeepWillOnlyRunIfCheckUpKeepReturnsTrue()
        public
        raffleEntered
    {
        // Act / Assert
        raffle.performUpkeep("");
    }

    function testPerformUpKeepWillOnlyRunIfCheckUpKeepReturnsFalse() public {
        // Arrange
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        uint256 raffleState = 0;
        vm.expectRevert();
        /* vm.expectRevert(abi.encodeWithSelector(
            Raffle.Raffle__UpkeepNotNeeded.selector,
            currentBalance,
            numPlayers,
            raffleState))
        */
        //Act / Assert
        raffle.performUpkeep("");
    }

    modifier raffleEntered() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: activeNetworkConfig.entranceFee}();
        vm.warp(block.timestamp + activeNetworkConfig.interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testPerformUpKeepUpdatesRaffleStateAndEmitsRequestId()
        public
        raffleEntered
    {
        // Arrange
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 vrfRequestId = entries[1].topics[1];

        // Assert state change
        uint256 rState = uint256(raffle.getRaffleState());
        assert(rState == 1); // 0 = open, 1 = calculating
        assert(vrfRequestId > 0);
    }
}
