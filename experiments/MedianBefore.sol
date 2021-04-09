contract MedianBefore {
    address[] public a;
    mapping(address => uint256) public bud;

    /**
     * @notice modifies MedianBefore.bud
     * @notice postcondition forall (uint i) !(0 <= i && i < a.length) || (bud[a[i]] == 1)
     * @notice postcondition a.length == __verifier_old_uint(a.length)
     * @notice postcondition forall (uint i) a[i] == __verifier_old_address(a[i])
     * @notice postcondition forall (address k) exists (uint j) (j < a.length && k == a[j]) || (bud[k] == __verifier_old_uint(bud[k]))
     */
    function kiss() public{
        uint256 i = 0;
        require(a.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (bud[a[j]] == 1)
         * @notice invariant !(i == a.length) || (bud[a[i-1]] == 1)
         * @notice invariant forall (uint j) a[j] == __verifier_old_address(a[j])
         * @notice invariant forall (address k) exists (uint j) (j < a.length && k == a[j]) || (bud[k] == __verifier_old_uint(bud[k]))
         */
        for (i = 0; i < a.length; i++) {
            bud[a[i]] = 1;
        }
    }

    /**
     * @notice modifies MedianBefore.bud
     * @notice postcondition forall (uint i) !(0 <= i && i < a.length) || (bud[a[i]] == 0)
     * @notice postcondition a.length == __verifier_old_uint(a.length)
     * @notice postcondition forall (uint i) a[i] == __verifier_old_address(a[i])
     * @notice postcondition forall (address k) exists (uint j) (j < a.length && k == a[j]) || (bud[k] == __verifier_old_uint(bud[k]))
     */
    function diss() public{
        uint256 i = 0;
        require(a.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (bud[a[j]] == 0)
         * @notice invariant !(i == a.length) || (bud[a[i-1]] == 0)
         * @notice invariant forall (uint j) a[j] == __verifier_old_address(a[j])
         * @notice invariant forall (address k) exists (uint j) (j < a.length && k == a[j]) || (bud[k] == __verifier_old_uint(bud[k]))
         */
        for (i = 0; i < a.length; i++) {
            bud[a[i]] = 0;
        }
    }
}
