pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import {ProfileSystem} from "../src/ProfileSystem.sol";

contract ProfileTest is Test, ProfileSystem {
    ProfileSystem public system;
    address user1 = address(0x1);

    function setUp() public {
        system = new ProfileSystem();
    }

    function testCreateProfile() public {
        vm.startPrank(user1); 
        system.createProfile("Noah");
        (string memory name, uint256 level, , ) = system.profiles(user1);
        assertEq(name, "Noah");
        assertEq(level, 1);
        vm.stopPrank();
    }
    
    function testCannotCreateEmptyProfile() public {
        vm.startPrank(user1);
        vm.expectRevert();
        system.createProfile("");
        vm.stopPrank();
    }

    function testCannotCreateDuplicateProfile() public {
        vm.startPrank(user1);
        system.createProfile("NOAH");
        vm.expectRevert();
        system.createProfile("NOAH");
        vm.stopPrank();
    }

    function testCannotLevelUpIfNotRegistered() public {
        vm.startPrank(user1);
        vm.expectRevert();
        system.levelUp();
        vm.stopPrank();
    }

    function testLevelUp() public {
        vm.startPrank(user1);
        system.createProfile("Noah");
        system.levelUp();
        ( , uint256 level, , ) = system.profiles(user1);
        assertEq(level, 2);
        vm.stopPrank();
    }
}