contract ArrayToolsAfter {
    uint256[] _array0;
    uint256 fullAmount0;

    /**
     * @notice modifies ArrayToolsAfter.fullAmount0
     * @notice postcondition fullAmount0 >= __verifier_old_uint(fullAmount0)
     * @notice postcondition fullAmount0 == __verifier_old_uint(fullAmount0) + __verifier_sum_uint(_array0)
     */
    function _combineArray0() public {
        uint256 initial = 0;
        uint256 initialSum = fullAmount0;
        uint256 loopcondition = _array0.length;
        fullAmount0 = _combineArray_for(initial, initialSum, loopcondition);
    }

    /**
     * @notice postcondition temp_total >= __verifier_old_uint(temp_total)
     * @notice postcondition loopcondition != _array0.length || initial != 0 || val == initialSum + __verifier_sum_uint(_array0)
     */
    function _combineArray_for(
        uint256 initial,
        uint256 initialSum,
        uint256 loopcondition
    ) internal returns (uint256) {
        uint256 temp_total = initialSum;
        /**
         * @notice invariant temp_total >= __verifier_old_uint(temp_total)
         * @notice invariant temp_total == __verifier_old_uint(temp_total) + sum(_array0[0] ... _array0[i])
         */
        for (uint256 i = initial; i < loopcondition; i++) {
            temp_total = temp_total + _array0[i];
        }
        return temp_total;
    }
}
