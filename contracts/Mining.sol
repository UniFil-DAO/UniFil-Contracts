// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./libs/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @dev Mining contract for XFIL
 */
contract Mining is Ownable {
    using SafeERC20 for IERC20;

    event Stake(address indexed account, uint256 amount);
    event Unstake(address indexed account, uint256 amount);

    IERC20 public stakingToken;
    uint256 public stakeStartTime;
    uint256 public stakeEndTime;
    uint256 public minPerUser;
    uint256 public maxPerUser;
    uint256 public maxTotalStake;
    uint256 public totalStaked;

    mapping(address => uint256) private _stakings;

    constructor(
        address _owner,
        address _stakingToken,
        uint256 _stakeStartTime,
        uint256 _stakeEndTime,
        uint256 _minPerUser,
        uint256 _maxPeruser,
        uint256 _maxTotalStake
    ) Ownable(_owner) {
        require(
            0 < _stakeStartTime && _stakeStartTime < _stakeEndTime && block.timestamp < _stakeEndTime,
            "Mining: invalid time limit"
        );
        require(_minPerUser <= _maxPeruser && _maxPeruser <= _maxTotalStake, "Mining: invalid amount limit");
        stakingToken = IERC20(_stakingToken);
        stakeStartTime = _stakeStartTime;
        stakeEndTime = _stakeEndTime;
        minPerUser = _minPerUser;
        maxPerUser = _maxPeruser;
        maxTotalStake = _maxTotalStake;
    }

    /**
     * @dev Returns staked token amount of `account`
     */
    function stakedOf(address account) public view returns (uint256) {
        return _stakings[account];
    }

    // ==================== EXTERNAL ====================

    /**
     * @dev Stake `amount` tokens
     */
    function stake(uint256 amount) external {
        _stake(msg.sender, amount);
    }

    // ==================== INTERNAL ====================

    /**
     * @dev Stake `amount` tokens from `account`
     */
    function _stake(address account, uint256 amount) internal {
        require(stakeStartTime <= block.timestamp && block.timestamp <= stakeEndTime, "Mining: not staking time");
        require(maxTotalStake > totalStaked, "Mining: no more staking");
        require(amount > 0, "Mining: stake amount is 0");
        uint256 remain = maxTotalStake - totalStaked;
        if (amount > remain) {
            amount = remain;
        }
        uint256 accTotal = _stakings[account] + amount;
        require(accTotal >= minPerUser, "Mining: less than min");
        require(accTotal <= maxPerUser, "Mining: more than max");
        _stakings[account] = accTotal;
        totalStaked += amount;

        stakingToken.safeTransferFrom(account, address(this), amount);
        emit Stake(account, amount);
    }

    /**
     * @dev Unstake `amount` tokens for `account`
     */
    function _unstake(address account, uint256 amount) internal {
        require(amount > 0, "Mining: unstake amount is 0");

        uint256 stakedBal = _stakings[account];
        require(amount <= stakedBal, "Mining: exceed staked amount");
        _stakings[account] = stakedBal - amount;
        totalStaked -= amount;

        stakingToken.safeTransfer(account, amount);
        emit Unstake(account, amount);
    }

    // ==================== Owner ====================

    /**
     * @dev Refund `amount` tokens for `account`
     */
    function refund(address account, uint256 amount) external onlyOwner {
        _unstake(account, amount);
    }
}
