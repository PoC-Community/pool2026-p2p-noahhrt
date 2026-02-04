pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
using SafeERC20 for IERC20;

contract Vault is Ownable, ReentrancyGuard {
    string private _baseTokenURI;
    uint256 private totalShares;
    IERC20 immutable asset;
    
    mapping(address => uint256) public sharesOf;

    event Deposit(address indexed user, uint256 assets, uint256 shares);
    event Withdraw(address indexed user, uint256 assets, uint256 shares);

    error ZeroAmount();
    error InsufficientShares();
    error ZeroShares();

    constructor(string memory baseURI_)
        Ownable(msg.sender)
    {
        _baseTokenURI = baseURI_;
        totalShares = 0;
    }

    // modifier nonReentrant() {
    //     require()
    //     _;
    // }

    function _convertToShares(uint256 assets) internal view returns (uint256)
    {
        if (totalShares == 0)
            revert ZeroShares();
        return ((assets * totalShares) / asset.balanceOf(address(this)));
    }

    function _convertToAssets(uint256 shares) internal view returns (uint256)
    {
        return (shares * asset.balanceOf(address(this))) / totalShares;
    }

    function deposit(uint256 assets) external returns (uint256 shares) {
        if (assets == 0)
            revert ZeroAmount();
        if (assets > 0 && _convertToShares(assets) > 0) {
            sharesOf[msg.sender] += _convertToShares(assets);
            totalShares += _convertToShares(assets);
            asset.safeTransferFrom(msg.sender, address(this), assets);
            emit Deposit(msg.sender, assets, _convertToShares(assets));
        }
        return _convertToShares(assets);
    }

    function withdraw(uint256 shares) public returns (uint256 assets) {
        if (shares == 0)
            revert ZeroAmount();
        if (shares > totalShares)
            revert InsufficientShares();
        if (shares > 0 && sharesOf[msg.sender] >= shares) {
            sharesOf[msg.sender] -= shares;
            totalShares -= shares;
            asset.safeTransfer(address(this), shares);
            emit Withdraw(msg.sender, _convertToAssets(shares), shares);
            return _convertToAssets(shares);
        }
    }

    function withdrawAll() public returns (uint256 assets)
    {
        emit Withdraw(msg.sender, _convertToAssets(totalShares), totalShares);
        return withdraw(sharesOf[msg.sender]);
    }

    function previewDeposit(uint256 assets) external view returns (uint256 shares)
    {
        return _convertToShares(assets);
    }

    function previewWithdraw(uint256 shares) external view returns (uint256 assets)
    {
        return _convertToAssets(shares);
    }
}