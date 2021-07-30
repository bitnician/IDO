// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./IDO.sol";

contract IDOFactory is Ownable {
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

    function createIDO(
        uint256 _tokenPrice,
        ERC20 _rewardToken,
        ERC20 _paymentToken,
        uint256 _startTimestamp,
        uint256 _finishTimestamp,
        uint256 _startClaimTimestamp,
        uint256 _minPayment,
        uint256 _maxPayment,
        uint256 _maxDistributedTokenAmount
    ) external {
        IDO ido = new IDO(
            _tokenPrice,
            _rewardToken,
            _paymentToken,
            _startTimestamp,
            _finishTimestamp,
            _startClaimTimestamp,
            _minPayment,
            _maxPayment,
            _maxDistributedTokenAmount,
            msg.sender
        );

        emit IDOCreated(
            msg.sender,
            address(ido),
            _tokenPrice,
            address(_rewardToken),
            _startTimestamp,
            _finishTimestamp,
            _startClaimTimestamp,
            _minPayment,
            _maxPayment,
            _maxDistributedTokenAmount
        );
    }
}
