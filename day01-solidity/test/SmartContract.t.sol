pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import {SmartContract} from "../src/SmartContract.sol";

contract SmartContractHelper is SmartContract, Test {
    function getAreYouABadPerson() public view returns (bool) {
        return _areYouABadPerson;
    }

    function testGetAreYouABadPerson() public view {
        assertEq(getAreYouABadPerson(), false);
    }

    function testSet() public {
        _setAreYouABadPerson(true);
        assertEq(_areYouABadPerson, true);
    }

    function testDataStruct() public view {
        assertEq(myInformations.firstName, "Noah");
        assertEq(myInformations.lastName, "Heurteaut");
        assertEq(myInformations.age, 21);
        assertEq(myInformations.city, "Paris");
    }
}