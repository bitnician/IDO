// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IIDOFactory {
    /// @notice Emitted when IDO is created
    /// @param owner the admin of IDO who can withdraw IDO contract balance
    /// @param idoPool the address of IDO
    /// @param tokenPrice the price of reward token base on payment token(or base on ETHER)
    /// @param rewardToken the address of reward token
    /// @param startTimestamp start time of IDO
    /// @param finishTimestamp finish time of IDO
    /// @param startClaimTimestamp start time for claiming reward tokens (by user)
    /// @param minPayment the min amount of payment token(or ETHER) that user can send to IDO contract
    /// @param maxPayment the max amount of payment token(or ETHER) that user can send to IDO contract
    /// @param maxDistributedTokenAmount the max token that can be distributed for IDO
    event IDOCreated(
        address owner,
        address idoPool,
        uint256 tokenPrice,
        address rewardToken,
        uint256 startTimestamp,
        uint256 finishTimestamp,
        uint256 startClaimTimestamp,
        uint256 minPayment,
        uint256 maxPayment,
        uint256 maxDistributedTokenAmount
    );

    /// @notice creates new IDO
    /// @param _tokenPrice the price of reward token base on payment token(or base on ETHER)
    /// @param _rewardToken the address of reward token
    /// @param _startTimestamp start time of IDO
    /// @param _finishTimestamp finish time of IDO
    /// @param _startClaimTimestamp start time for claiming reward tokens (by user)
    /// @param _minPayment the min amount of payment token(or ETHER) that user can send to IDO contract
    /// @param _maxPayment the max amount of payment token(or ETHER) that user can send to IDO contract
    /// @param _maxDistributedTokenAmount the max token that can be distributed for IDO
    function createIDO(
        uint256 _tokenPrice,
        address _rewardToken,
        address _paymentToken,
        uint256 _startTimestamp,
        uint256 _finishTimestamp,
        uint256 _startClaimTimestamp,
        uint256 _minPayment,
        uint256 _maxPayment,
        uint256 _maxDistributedTokenAmount
    ) external;
}
