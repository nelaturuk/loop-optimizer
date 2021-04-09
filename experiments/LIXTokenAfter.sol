contract LIXTokenAfter {
    uint256 public operVestingTime0;
    mapping(uint256 => uint256) public operVestingTimer0;
    uint256 public lockTime0;

    /**
     * @notice modifies LIXTokenAfter.operVestingTimer0
     * @notice postcondition forall (uint i) !(1 <= i && i < operVestingTime0) || (operVestingTimer0[i] == lockTime0)
     * @notice postcondition operVestingTime0 == __verifier_old_uint(operVestingTime0)
     * @notice postcondition exists (uint j) (j < operVestingTime0) || (operVestingTimer0[j] == __verifier_old_uint(operVestingTimer0[j]))
     */
    function endSale0() public {
        uint256 rvariable = lockTime0;
        uint256 initial = 1;
        uint256 loopcondition = operVestingTime0;
        endSale_for(rvariable, initial, loopcondition);
    }

    /**
     * @notice modifies LIXTokenAfter.operVestingTimer0
     * @notice postcondition forall (uint i) !(1 <= i && i < loopcondition) || (operVestingTimer0[i] == rvariable)
     * @notice postcondition loopcondition == __verifier_old_uint(loopcondition)
     * @notice postcondition exists (uint j) (j < loopcondition) || (operVestingTimer0[j] == __verifier_old_uint(operVestingTimer0[j]))
     */
    function endSale_for(
        uint256 rvariable,
        uint256 initial,
        uint256 loopcondition
    ) internal {
        uint256 i = 1;
        require(loopcondition > 0);
         /**
         * @notice invariant forall (uint j) (j >= i || j < 1 ) || (operVestingTimer0[j] == rvariable)
         * @notice invariant exists (uint j) (j < operVestingTime0) || (operVestingTimer0[j] == __verifier_old_uint(operVestingTimer0[j]))
         */
        for (i = initial; i < loopcondition; i++) {
            operVestingTimer0[i] = rvariable;
        }
    }
}
