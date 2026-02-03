pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import {PoolToken} from "../src/PoolToken.sol";

contract PoolTokenTest is Test {
    PoolToken public token;
    address user = address(0x1);
    address owner = address(0x2);
    uint256 INITIAL_SUPPLY = 20;
    function setUp() public {
        vm.prank(owner);
        token = new PoolToken(20);
        vm.stopPrank();
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function testOnlyOwnerCanMint() public {
        vm.prank(user);
        vm.expectRevert();
        token.mint(user, 1000 ether);
    }
}