// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract IDO is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    uint256 public tokenPrice;
    ERC20 public rewardToken;
    ERC20 public paymentToken;
    uint256 public decimals;
    uint256 public startTimestamp;
    uint256 public finishTimestamp;
    uint256 public startClaimTimestamp;
    uint256 public minPayment;
    uint256 public maxPayment;
    uint256 public maxDistributedTokenAmount;
    uint256 public tokensForDistribution;
    uint256 public distributedTokens;
    address public WETHAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    bool public payInEther;
    address public owner;

    struct UserInfo {
        address account;
        uint256 debt;
        uint256 total;
        uint256 totalInvested;
        bool invested;
    }

    //user address => userInfo
    mapping(address => UserInfo) public userInfo;
    address[] public userAddresses;
    uint256 public userCount;

    event TokensDebt(
        address indexed holder,
        uint256 depositedAmount,
        uint256 rewardAmount
    );

    event TokensWithdrawn(address indexed holder, uint256 amount);

    constructor(
        uint256 _tokenPrice,
        ERC20 _rewardToken,
        ERC20 _paymentToken,
        uint256 _startTimestamp,
        uint256 _finishTimestamp,
        uint256 _startClaimTimestamp,
        uint256 _minPayment,
        uint256 _maxPayment,
        uint256 _maxDistributedTokenAmount,
        address _owner
    ) {
        require(
            _startTimestamp < _finishTimestamp,
            "Start timestamp must be less than finish timestamp"
        );
        require(
            _finishTimestamp > block.timestamp,
            "Finish timestamp must be more than current block"
        );

        tokenPrice = _tokenPrice;
        rewardToken = ERC20(_rewardToken);
        paymentToken = ERC20(_paymentToken);
        startTimestamp = _startTimestamp;
        finishTimestamp = _finishTimestamp;
        startClaimTimestamp = _startClaimTimestamp;
        minPayment = _minPayment;
        maxPayment = _maxPayment;
        maxDistributedTokenAmount = _maxDistributedTokenAmount;

        payInEther = address(_paymentToken) == WETHAddress ? true : false;

        owner = _owner;
        decimals = 18;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    modifier checkMinMaxPayment(uint256 amount) {
        require(amount >= minPayment, "Less then min amount");
        require(amount <= maxPayment, "More then max amount");

        _;
    }

    modifier checkTimespan() {
        require(block.timestamp >= startTimestamp, "Not started");
        require(block.timestamp < finishTimestamp, "Ended");

        _;
    }

    modifier isEtherPaymentMethod() {
        require(payInEther, "ether payment has not been activate");
        _;
    }

    function payWithEther()
        external
        payable
        checkMinMaxPayment(msg.value)
        checkTimespan
        isEtherPaymentMethod
    {
        uint256 rewardTokenAmount = getTokenAmount(msg.value);

        tokensForDistribution = tokensForDistribution.add(rewardTokenAmount);

        require(
            tokensForDistribution <= maxDistributedTokenAmount,
            "Overfilled"
        );

        updateUserInfo(msg.sender, msg.value, rewardTokenAmount);

        emit TokensDebt(msg.sender, msg.value, rewardTokenAmount);
    }

    function payWithToken(uint256 depositedAmount)
        external
        payable
        checkMinMaxPayment(depositedAmount)
        checkTimespan
    {
        paymentToken.safeTransferFrom(
            msg.sender,
            address(this),
            depositedAmount
        );

        uint256 rewardTokenAmount = getTokenAmount(depositedAmount);

        tokensForDistribution = tokensForDistribution.add(rewardTokenAmount);

        require(
            tokensForDistribution <= maxDistributedTokenAmount,
            "Overfilled"
        );

        updateUserInfo(msg.sender, depositedAmount, rewardTokenAmount);

        emit TokensDebt(msg.sender, depositedAmount, rewardTokenAmount);
    }

    function getTokenAmount(uint256 depositedAmount)
        public
        view
        returns (uint256)
    {
        return depositedAmount.mul(10**decimals).div(tokenPrice);
    }

    function updateUserInfo(
        address userAddress,
        uint256 depositedAmount,
        uint256 rewardTokenAmount
    ) private {
        UserInfo storage user = userInfo[userAddress];
        require(
            user.totalInvested.add(depositedAmount) <= maxPayment,
            "More then max amount"
        );

        user.account = userAddress;
        user.totalInvested = user.totalInvested.add(msg.value);
        user.total = user.total.add(rewardTokenAmount);
        user.debt = user.debt.add(rewardTokenAmount);
    }

    function increaseUserCount(UserInfo storage _userInfo) private {
        if (!_userInfo.invested) {
            userAddresses.push(_userInfo.account);
            userCount++;
            _userInfo.invested = true;
        }
    }

    function claimFor(address _user) external {
        proccessClaim(_user);
    }

    /// @dev Allows to claim tokens for themselves.
    function claim() external {
        proccessClaim(msg.sender);
    }

    function proccessClaim(address _receiver) internal nonReentrant {
        require(
            block.timestamp > startClaimTimestamp,
            "Distribution not started"
        );
        UserInfo storage user = userInfo[_receiver];
        uint256 _amount = user.debt;
        if (_amount > 0) {
            user.debt = 0;
            distributedTokens = distributedTokens.add(_amount);
            rewardToken.safeTransfer(_receiver, _amount);
            emit TokensWithdrawn(_receiver, _amount);
        }
    }

    function withdrawETH(uint256 amount)
        external
        onlyOwner
        isEtherPaymentMethod
    {
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed.");
    }

    function withdrawPaymentToken(uint256 amount) external onlyOwner {
        paymentToken.safeTransfer(msg.sender, amount);
    }

    function withdrawNotSoldTokens() external onlyOwner {
        require(
            block.timestamp > finishTimestamp,
            "Withdraw allowed after finish timestamp"
        );
        uint256 balance = rewardToken.balanceOf(address(this));
        rewardToken.safeTransfer(
            msg.sender,
            balance.add(distributedTokens).sub(tokensForDistribution)
        );
    }
}
