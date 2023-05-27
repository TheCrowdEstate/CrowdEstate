// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IErrors {
    /// @notice Error for when the shares are equal or less than zero
    error SharesMustBeGreaterThanZero();

    /// @notice Error for when the amount is equal or less than zero
    error AmountMustBeGreaterThanZero();

    /// @notice Error for when you input an invalid property id
    error InvalidPropertyId();

    /// @notice Error for when you don't have enough shares
    error NotEnoughSharesAvailable();

    /// @notice Error when there is no balance in the contract to withdraw
    error NoBalanceToWithdraw();

    /// @notice Error when your share balance is less than or equal to zero
    error InsufficientSharesBalance();

    /// @notice Error when the share amount does not match the value sent
    error SentAmountDoesNotMatchShare();

    /// @notice Error when there is no shares to cancel your otc order
    error InsufficientSharesToCancel();
}
