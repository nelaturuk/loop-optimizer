contract WPXBefore {
    struct LockInfo {
        uint256 _releaseTime;
        uint256 _amount;
    }

    address public implementation;

    LockInfo[] public timelockList;
    mapping(address => bool) public frozenAccount;
    uint256 totalBalance;

    /**
     * @notice modifies WPXBefore.totalBalance
     * @notice postcondition totalBalance >= __verifier_old_uint(totalBalance)
     * @notice postcondition totalBalance == __verifier_old_uint(totalBalance) + __verifier_sum_uint(timelockList._amount)
     */
    function balanceOf() public {
        if (timelockList.length > 0) {
            uint256 i = 0;
            require(timelockList.length > 0);
            /**
             * @notice invariant totalBalance >= __verifier_old_uint(totalBalance)
             * @notice invariant totalBalance == __verifier_old_uint(totalBalance) + sum(totalBalance[0]._amount ... totalBalance[i]._amount)
             */
            for (i = 0; i < timelockList.length; i++) {
                totalBalance = totalBalance + timelockList[i]._amount;
            }
        }
    }
}
