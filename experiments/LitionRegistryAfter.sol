contract LitionRegistryAfter {
    address[] public validators0;
    mapping(address => bool) public miningValidators0;

    /**
     * @notice modifies LitionRegistryAfter.miningValidators0
     * @notice postcondition forall (uint i) !(0 <= i && i < validators0.length) || (miningValidators0[validators0[i]] == true)
     * @notice postcondition forall (uint j) validators0[j] == __verifier_old_address(validators0[j])
     * @notice postcondition validators0.length == __verifier_old_uint(validators0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < validators0.length && a == validators0[j]) || (miningValidators0[a] == __verifier_old_bool(miningValidators0[a]))
     */
  function processValidatorsRewards20() public {
    bool rvariable = true; 
    uint loopcondition = validators0.length;
    processValidatorsRewards2_for(rvariable, loopcondition);
  }

  /**
     * @notice modifies LitionRegistryAfter.miningValidators0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (miningValidators0[validators0[i]] == rvariable)
     * @notice postcondition forall (uint j) validators0[j] == __verifier_old_address(validators0[j])
     * @notice postcondition validators0.length == __verifier_old_uint(validators0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && a == validators0[j]) || (miningValidators0[a] == __verifier_old_bool(miningValidators0[a]))
     */
  function processValidatorsRewards2_for(bool rvariable, uint loopcondition) internal {

      uint256 i = 0;
        require(loopcondition > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (miningValidators0[validators0[j]] == rvariable)
         * @notice invariant !(i == loopcondition) || (miningValidators0[validators0[i-1]] == rvariable)
         * @notice invariant forall (uint j) validators0[j] == __verifier_old_address(validators0[j])
         * @notice invariant forall (address a) exists (uint j) (j < loopcondition && a == validators0[j]) || (miningValidators0[a] == __verifier_old_bool(miningValidators0[a]))
         */
  for (i = 0; i < loopcondition; i++) {
    miningValidators0[validators0[i]] = rvariable;
   }
  }
 
}