contract AllocationsAfter {
    struct Payout {
        uint64 startTime;
        uint64 recurrences;
        uint64 period;
        address[] candidateAddresses;
        uint256[] support;
        uint64[] executions;
        uint256 amount;
        string description;
    }
    Payout payout0;
    uint256 totalSupport0;

    /**
     * @notice modifies AllocationsAfter.totalSupport0
     * @notice postcondition totalSupport0 >= __verifier_old_uint(totalSupport0)
     * @notice postcondition totalSupport0 == __verifier_old_uint(totalSupport0) + __verifier_sum_uint(payout0.support)
     */
    function _getTotalSupport0() public {
        uint256 initial = 0;
        uint256 initialSum = totalSupport0;
        uint256 loopcondition = payout0.support.length;
        totalSupport0 = _getTotalSupport_for(initial, initialSum, loopcondition);
    }

    /**
     * @notice modifies temp_total
     * @notice postcondition temp_total >= __verifier_old_uint(temp_total)
     * @notice postcondition temp_total == __verifier_old_uint(temp_total) + __verifier_sum_uint(payout0.support)
     */
    function _getTotalSupport_for(
        uint256 initial,
        uint256 initialSum,
        uint256 loopcondition
    ) internal returns (uint256) {
        uint256 i = 0;
        uint256 temp_total = initialSum;
        require(loopcondition > 0);
        require(temp_total > 0);
        /**
         * @notice invariant temp_total >= __verifier_old_uint(temp_total)
         * @notice invariant temp_total == __verifier_old_uint(temp_total) + __verifier_sum_uint(payout0.support)
         * @notice invariant temp_total == __verifier_old_uint(temp_total) + sum(_tokens0[0] ... _tokens0[i])
         */

        for (i = initial; i < loopcondition; i++) {
            temp_total = temp_total + payout0.support[i];
        }
        return temp_total;
    }
}
