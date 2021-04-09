contract AllocationsBefore {

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
    Payout public payout;
    uint256 public totalSupport;
    

    /**
     * @notice modifies AllocationsBefore.totalSupport
     * @notice postcondition totalSupport >= __verifier_old_uint(totalSupport)
     * @notice postcondition totalSupport == __verifier_old_uint(totalSupport) + __verifier_sum_uint(payout.support)
     */
    function _getTotalSupport() public{
         uint256 i = 0;
        require(payout.support.length > 0);
        require(totalSupport > 0);
        /**
         * @notice invariant totalSupport >= __verifier_old_uint(totalSupport)
         * @notice invariant totalSupport == __verifier_old_uint(totalSupport) + __verifier_sum_uint(payout.support)
         * @notice invariant total0 == __verifier_old_uint(total0) + sum(_tokens0[0] ... _tokens0[i])
         */
        for (i = 0; i < payout.support.length; i++) {
            totalSupport += payout.support[i];
        }
    }
}