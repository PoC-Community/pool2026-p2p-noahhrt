pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
using SafeERC20 for IERC20;

contract Vault is Ownable, ReentrancyGuard {
    IERC20 immutable asset;
    uint256 private totalShares;
    mapping(address => uint256) public sharesOf;

    event Deposit(address indexed user, uint256 assets, uint256 shares);
    event Withdraw(address indexed user, uint256 assets, uint256 shares);
    event RewardAdded(uint256 ammont);

    error ZeroAmount();
    error InsufficientShares();
    error ZeroShares();

    constructor(address _asset)
        Ownable(msg.sender)
    {
        asset = IERC20(_asset);
        totalShares = 0;
    }

    function _convertToShares(uint256 assets) internal view returns (uint256)
    {
        if (totalShares == 0)
            return assets;
        return ((assets * totalShares) / asset.balanceOf(address(this)));
    }

    function _convertToAssets(uint256 shares) internal view returns (uint256)
    {
        return (shares * asset.balanceOf(address(this))) / totalShares;
    }

    function deposit(uint256 assets) external nonReentrant returns (uint256 shares) {
        if (assets == 0)
            revert ZeroAmount();
        shares = _convertToShares(assets);
        if (_convertToShares(assets) ==  0) {
            revert InsufficientShares();
        }
        sharesOf[msg.sender] += _convertToShares(assets);
        totalShares += _convertToShares(assets);
        asset.safeTransferFrom(msg.sender, address(this), assets);
        emit Deposit(msg.sender, assets, _convertToShares(assets));
    }

    function withdraw(uint256 shares) public nonReentrant returns (uint256 assets) {
        if (shares == 0)
            revert ZeroAmount();
        assets = _convertToAssets(shares);
        require(shares > totalShares, "ERROR OCCUR SHARES > TOTALSHARES");
        if (sharesOf[msg.sender] < shares) {
            revert InsufficientShares();
        }
        sharesOf[msg.sender] -= shares;
        totalShares -= shares;
        asset.safeTransfer(address(this), shares);
        emit Withdraw(msg.sender, _convertToAssets(shares), shares);
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

    function totalAssets() public view returns (uint256 total_assets)
    {
        return asset.balanceOf(address(this));    
    }

    function currentRatio() external view returns (uint256 ratio) {
        if (totalShares == 0)
            return (1e18);
        return (asset.balanceOf(address(this)) * 1e18) / totalShares;
    }

    function assetsOf(address user) external view returns (uint256 assets) {
        return _convertToAssets(sharesOf[user]);
    }

    function addReward(uint256 amount) external onlyOwner nonReentrant {
        if (amount > 0 && totalShares > 0) {
            asset.safeTransferFrom(msg.sender, address(this), amount);
            emit RewardAdded(amount);
        }
    }
}