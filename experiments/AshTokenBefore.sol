contract AshTokenBefore {
    uint256 public totalSupply;

    address[] _addrs;
    uint256[] _amounts;

    /**
     * @notice modifies AshTokenBefore.totalSupply
     * @notice postcondition totalSupply >= __verifier_old_uint(totalSupply)
     * @notice postcondition totalSupply == __verifier_old_uint(totalSupply) + __verifier_sum_uint(_amounts)
     */
    function init() public {
        uint256 i = 0;
        require(_addrs.length > 0);
        /**
         * @notice invariant totalSupply >= __verifier_old_uint(totalSupply)
         * @notice invariant totalSupply == __verifier_old_uint(totalSupply) + sum(_amounts[0] ... _amounts[i])
         */
        for (i = 0; i < _addrs.length; i++) {
            totalSupply = totalSupply + _amounts[i];
        }
    }
}