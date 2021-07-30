// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IIDO {
    /// @notice Emitted when user buy token
    /// @param holder the address of user who want to participate in ido
    /// @param depositedAmount the amount that has been sent by the user to get some reward token
    /// @param rewardAmount the amount that has been sent to user address
    event TokensDebt(
        address indexed holder,
        uint256 depositedAmount,
        uint256 rewardAmount
    );

    /// @notice Emitted when user withdraw his/her reward token
    /// @param holder the address of user who has participated in ido
    /// @param amount the withdrawal amount
    event TokensWithdrawn(address indexed holder, uint256 amount);

    /// @notice gets the count of token holders
    function getUserCount() external;

    /// @notice pays ether to get reward token
    function payWithEther() external payable;

    /// @notice pays erc20 token to get reward token
    /// @param depositedAmount the amount of erc20 token
    function payWithToken(uint256 depositedAmount) external;

    /// @notice calculates the amount of reward token that will be sent to user
    /// @param depositedAmount the amount of erc20 token or ether that is deposited
    /// @return the amount of reward token
    function getTokenAmount(uint256 depositedAmount)
        external
        view
        returns (uint256);

    /// @notice allows to claim tokens for the specific user.
    /// @param _user token receiver.
    function claimFor(address _user) external;

    /// @notice allows to claim tokens for themselves.
    function claim() external;

    /// @notice allows owner to withdraw ethers from contract.
    /// @param amount amount of ethers.
    function withdrawETH(uint256 amount) external;

    /// @notice allows owner to withdraw erc20 token(payment token) from contract.
    /// @param amount amount of ethers.
    function withdrawPaymentToken(uint256 amount) external;

    /// @notice allows admin to withdraw non solden reward token.
    function withdrawNotSoldTokens() external;
}
