// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import "./interfaces/IWithUnderlying.sol";

/**
 * @title WithUnderlying
 * @notice A helper contract to handle the inflow and outflow of ERC20 tokens.
 * @dev Utilizes OpenZeppelin's SafeERC20 library to handle ERC20 transactions.
 */
abstract contract WithUnderlying is Initializable, IWithUnderlying {
    using SafeERC20 for IERC20;

    address public underlying;

    /**
     * @notice Initialies the abstract contract instance.
     * @param _underlying The address of the underlying ERC20 token.
     */
    function __WithUnderlying_init(address _underlying) internal onlyInitializing {
        underlying = _underlying;
    }

    /**
     * @notice Handles the inflow of tokens to the contract.
     * @dev Transfers `_amount` tokens from `_from` to this contract and returns the actual amount received.
     * @param _from The address from which tokens are transferred.
     * @param _amount The amount of tokens to transfer.
     * @return The actual amount of tokens received by the contract.
     */
    function _inflowTokens(address _from, uint256 _amount) internal returns (uint256) {
        uint256 balanceBefore = IERC20(underlying).balanceOf(address(this));
        IERC20(underlying).safeTransferFrom(_from, address(this), _amount);
        uint256 balanceAfter = IERC20(underlying).balanceOf(address(this));
        return balanceAfter - balanceBefore;
    }

    /**
     * @notice Handles the outflow of tokens from the contract.
     * @dev Transfers `_amount` tokens from this contract to `_to` and returns the actual amount sent.
     * @param _to The address to which tokens are transferred.
     * @param _amount The amount of tokens to transfer.
     * @return The actual amount of tokens sent from the contract.
     */
    function _outflowTokens(address _to, uint256 _amount) internal returns (uint256) {
        uint256 balanceBefore = IERC20(underlying).balanceOf(address(this));
        IERC20(underlying).safeTransfer(_to, _amount);
        uint256 balanceAfter = IERC20(underlying).balanceOf(address(this));
        return balanceBefore - balanceAfter;
    }
}
