contract OSMAfter {
    address[] a0;
    mapping(address => uint256) public bud0;

    /**
     * @notice modifies OSMAfter.bud0
     * @notice postcondition forall (uint i) !(0 <= i && i < a0.length) || (bud0[a0[i]] == 0)
     * @notice postcondition a0.length == __verifier_old_uint(a0.length)
     * @notice postcondition forall (uint i) a0[i] == __verifier_old_address(a0[i])
     * @notice postcondition forall (address k) exists (uint j) (j < a0.length && k == a0[j]) || (bud0[k] == __verifier_old_uint(bud0[k]))
     */
    function diss0() public {
        uint256 rvariable = 0;
        uint256 loopcondition = a0.length;
        diss_for(rvariable, loopcondition);
    }

    /**
     * @notice modifies OSMAfter.bud0
     * @notice postcondition forall (uint i) !(0 <= i && i < a0.length) || (bud0[a0[i]] == rvariable)
     * @notice postcondition a0.length == __verifier_old_uint(a0.length)
     * @notice postcondition forall (uint i) a0[i] == __verifier_old_address(a0[i])
     * @notice postcondition forall (address k) exists (uint j) (j < a0.length && k == a0[j]) || (bud0[k] == __verifier_old_uint(bud0[k]))
     */
    function diss_for(uint256 rvariable, uint256 loopcondition) internal {
        uint256 i = 0;
        require(a0.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (bud0[a0[j]] == rvariable)
         * @notice invariant !(i == a0.length) || (bud0[a0[i-1]] == rvariable)
         * @notice invariant forall (uint j) a0[j] == __verifier_old_address(a0[j])
         * @notice invariant forall (address k) exists (uint j) (j < a0.length && k == a0[j]) || (bud0[k] == __verifier_old_uint(bud0[k]))
         */
        for (i = 0; i < loopcondition; i++) {
            bud0[a0[i]] = rvariable;
        }
    }

    /**
     * @notice modifies OSMAfter.bud0
     * @notice postcondition forall (uint i) !(0 <= i && i < a0.length) || (bud0[a0[i]] == 1)
     * @notice postcondition a0.length == __verifier_old_uint(a0.length)
     * @notice postcondition forall (uint i) a0[i] == __verifier_old_address(a0[i])
     * @notice postcondition forall (address k) exists (uint j) (j < a0.length && k == a0[j]) || (bud0[k] == __verifier_old_uint(bud0[k]))
     */
    function kiss0() public {
        uint256 rvariable = 1;
        uint256 loopcondition = a0.length;
        kiss_for(rvariable, loopcondition);
    }

    /**
     * @notice modifies OSMAfter.bud0
     * @notice postcondition forall (uint i) !(0 <= i && i < a0.length) || (bud0[a0[i]] == rvariable)
     * @notice postcondition a0.length == __verifier_old_uint(a0.length)
     * @notice postcondition forall (uint i) a0[i] == __verifier_old_address(a0[i])
     * @notice postcondition forall (address k) exists (uint j) (j < a0.length && k == a0[j]) || (bud0[k] == __verifier_old_uint(bud0[k]))
     */
    function kiss_for(uint256 rvariable, uint256 loopcondition) internal {
        uint256 i = 0;
        require(a0.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (bud0[a0[j]] == rvariable)
         * @notice invariant !(i == a0.length) || (bud0[a0[i-1]] == rvariable)
         * @notice invariant forall (uint j) a0[j] == __verifier_old_address(a0[j])
         * @notice invariant forall (address k) exists (uint j) (j < a0.length && k == a0[j]) || (bud0[k] == __verifier_old_uint(bud0[k]))
         */
        for (i = 0; i < loopcondition; i++) {
            bud0[a0[i]] = rvariable;
        }
    }
}
