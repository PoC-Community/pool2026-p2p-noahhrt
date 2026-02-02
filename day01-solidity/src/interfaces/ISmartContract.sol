pragma solidity ^0.8.20;
interface ISmartContract {
    enum roleEnum {STUDENT, TEACHER}
    struct Informations {
        string firstName;
        string lastName;
        uint8 age;
        string city;
        roleEnum role;
    }
    function getHalfAnswerOfLife() external view returns (uint256);
    function _getMyEthereumContractAddress() external view returns (address);
    function getPoCIsWhat() external view returns (string memory);
    function editMyCity(string calldata _newCity) external;
    function getMyFullName() external view returns (string memory);
    function hashMyMessage(string calldata _message) external pure returns (bytes32);
    function getMyBalance() external view returns (uint256);
    function addToBalance() external payable;
    function withdrawFromBalance(uint256 _amount) external;
    event BalanceUpdated(address indexed user, uint256 newBalance);
    error InsufficientBalance(uint256 available, uint256 requested);
}

abstract contract SmartContract is ISmartContract {}
