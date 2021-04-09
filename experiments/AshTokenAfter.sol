contract AshTokenAfter {
    uint256 public totalSupply0;
    address[] _addrs0;
    uint256[] _amounts0;

    /**
     * @notice modifies AshTokenAfter.totalSupply0
     * @notice postcondition totalSupply0 >= __verifier_old_uint(totalSupply0)
     * @notice postcondition totalSupply0 == __verifier_old_uint(totalSupply0) + __verifier_sum_uint(_amounts0)
     */
    function init0() public {
        uint256 initial = 0;
        uint256 initialSum = totalSupply0;
        uint256 loopcondition = _addrs0.length;
        totalSupply0 = init_for(initial, initialSum, loopcondition);
    }

    /**
     * @notice postcondition temp_total >= __verifier_old_uint(temp_total)
     * @notice postcondition loopcondition != _amounts0.length || initial != 0 || val == initialSum + __verifier_sum_uint(_amounts0)
     */
    function init_for(
        uint256 initial,
        uint256 initialSum,
        uint256 loopcondition
    ) internal returns (uint256) {
        uint256 temp_total = initialSum;
        /**
         * @notice invariant temp_total >= __verifier_old_uint(temp_total)
         * @notice invariant temp_total == __verifier_old_uint(temp_total) + sum(_amounts0[0] ... _amounts0[i])
         */
        for (uint256 i = initial; i < loopcondition; i++) {
            temp_total = temp_total + _amounts0[i];
        }
        return temp_total;
    }
}
