contract ISDTAfter {
    struct VotedResult0 {
        bool result;
    }

    mapping(uint256 => VotedResult0) public voteBox0;

    uint256 public MAX_JUDGE0;

    /**
     * @notice modifies ISDTAfter.voteBox0
     * @notice postcondition forall (uint i) !(0 <= i && i < MAX_JUDGE0) || (voteBox0[i].result == false)
     * @notice postcondition MAX_JUDGE0 == __verifier_old_uint(MAX_JUDGE0)
     * @notice postcondition exists (uint j) (j < MAX_JUDGE0) || (voteBox0[j].result == __verifier_old_bool(voteBox0[j].result))
     */
    function _voteResult0() public {
        bool rvariable = false;
        uint24 initial = 0;
        uint256 loopcondition = MAX_JUDGE0;
        _voteResult_for(rvariable, initial, loopcondition);
    }

    /**
     * @notice modifies ISDTAfter.voteBox0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (voteBox0[i].result == rvariable)
     * @notice postcondition loopcondition == __verifier_old_uint(loopcondition)
     * @notice postcondition exists (uint j) (j < loopcondition) || (voteBox0[j].result == __verifier_old_bool(voteBox0[j].result))
     */
    function _voteResult_for(
        bool rvariable,
        uint256 initial,
        uint256 loopcondition
    ) internal {
        uint256 i = 0;
        require(loopcondition > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (voteBox0[j].result == rvariable)
         * @notice invariant !(i == MAX_JUDGE0) || (voteBox0[i-1].result == rvariable)
         * @notice invariant exists (uint j) (j < MAX_JUDGE0) || (voteBox0[j].result == __verifier_old_bool(voteBox0[j].result))
         */
        for (i = initial; i < loopcondition; i++) {
            voteBox0[i].result = rvariable;
        }
    }
}
