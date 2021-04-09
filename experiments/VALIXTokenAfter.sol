contract VALLIXTokenAfter {
    uint256 private constant E18 = 1000000000000000000;
    uint256 public constant teamVestingSupplyPerTime = 100000000 * E18;
    uint256 public constant teamVestingTime = 16;

    uint256 public totalTokenSupply;

    mapping(uint256 => uint256) public teamVestingTimeAtSupply;

    function endSale() public {
        uint256 rvariable = 100;
        uint256 initial = 1;
        uint256 loopcondition = teamVestingTime;
        endSale_for(rvariable, initial, loopcondition);
    }

    function endSale_for(
        uint256 rvariable,
        uint256 initial,
        uint256 loopcondition
    ) internal {
        for (uint256 i = initial; i < loopcondition; i++) {
            teamVestingTimeAtSupply[i] = rvariable;
        }
    }

    /**
     * @notice modifies WPXAfter.totalBalance0
     * @notice postcondition totalBalance0 >= __verifier_old_uint(totalBalance0)
     * @notice postcondition totalBalance0 == __verifier_old_uint(totalBalance0) + __verifier_sum_uint(timelockList0._amount)
     */
    function balanceOf0() public {
        uint256 initial = 0;
        uint256 initialSum = totalBalance0;
        uint256 loopcondition = timelockList0.length;
        if (loopcondition > 0) {
            totalBalance0 = balanceOf_for(initial, initialSum, loopcondition);
        }
    }

    /**
     * @notice postcondition temp_total >= __verifier_old_uint(temp_total)
     * @notice postcondition loopcondition != timelockList0.length || initial != 0 || val == initialSum + __verifier_sum_uint(timelockList0._amount)
     */
    function balanceOf_for(
        uint256 initial,
        uint256 initialSum,
        uint256 loopcondition
    ) internal returns (uint256) {
        uint256 temp_total = initialSum;
        /**
         * @notice invariant temp_total >= __verifier_old_uint(temp_total)
         * @notice invariant temp_total == __verifier_old_uint(temp_total) + sum(timelockList0[0]._amount ... timelockList0[i]._amount)
         */
        for (uint256 i = initial; i < loopcondition; i++) {
            temp_total = temp_total + timelockList0[i]._amount;
        }
        return temp_total;
    }
}
