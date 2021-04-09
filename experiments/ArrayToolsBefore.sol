contract ArrayToolsBefore {
    uint256[] _array;
     uint256 fullAmount;

    /**
     * @notice modifies ArrayToolsBefore.fullAmount
     * @notice postcondition fullAmount >= __verifier_old_uint(fullAmount)
     * @notice postcondition fullAmount == __verifier_old_uint(fullAmount) + __verifier_sum_uint(_array)
     */
    function _combineArray() public {
        uint256 i = 0;
        require(_array.length > 0);
        /**
         * @notice invariant fullAmount >= __verifier_old_uint(fullAmount)
         * @notice invariant fullAmount == __verifier_old_uint(fullAmount) + sum(_array[0] ... _array[i])
         */
        for(i = 0; i < _array.length; i++) {
            // require(_array[i] > 0);
            fullAmount += _array[i];
        }
    }
}