contract ISDTBefore {
    
    struct VotedResult {
        bool result;
    }

    mapping(uint256 => VotedResult) public voteBox;

    uint256 public MAX_JUDGE;

    /**
     * @notice modifies ISDTBefore.voteBox
     * @notice postcondition forall (uint i) !(0 <= i && i < MAX_JUDGE) || (voteBox[i].result == false)
     * @notice postcondition MAX_JUDGE == __verifier_old_uint(MAX_JUDGE)
     * @notice postcondition exists (uint j) (j < MAX_JUDGE) || (voteBox[j].result == __verifier_old_bool(voteBox[j].result))
     */
    function _voteResult() public {
        uint256 i = 0;
        require(MAX_JUDGE > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (voteBox[j].result == false)
         * @notice invariant !(i == MAX_JUDGE) || (voteBox[i-1].result == false)
         * @notice invariant exists (uint j) (j < MAX_JUDGE) || (voteBox[j].result == __verifier_old_bool(voteBox[j].result))
         */
        for(i = 0; i < MAX_JUDGE; i++) {
            voteBox[i].result = false;
        }
    }

}