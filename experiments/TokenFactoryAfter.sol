contract TokenFactoryAfter {

  address[] public _auditSelectors0;
  bool[] public values0;

  /**
     * @notice modifies TokenFactoryAfter.values0
     * @notice postcondition forall (uint i) !(0 <= i && i < _auditSelectors0.length) || (values0[i] == true)
     * @notice postcondition forall (uint j) _auditSelectors0[j] == __verifier_old_address(_auditSelectors0[j])
     * @notice postcondition _auditSelectors0.length == __verifier_old_uint(_auditSelectors0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < _auditSelectors0.length) || (values0[j] == __verifier_old_bool(values0[j]))
     */
  function reviewToken0() public {
    bool rvariable = true; 
    uint initial = 0;
    uint loopcondition = _auditSelectors0.length;
    reviewToken_for(rvariable, initial, loopcondition);
  }

  /**
     * @notice modifies TokenFactoryAfter.values0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (values0[i] == rvariable)
     * @notice postcondition forall (uint j) _auditSelectors0[j] == __verifier_old_address(_auditSelectors0[j])
     * @notice postcondition _auditSelectors0.length == __verifier_old_uint(_auditSelectors0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < loopcondition) || (values0[j] == __verifier_old_bool(values0[j]))
     */
  function reviewToken_for(bool rvariable, uint initial, uint loopcondition) internal {

    uint256 i = 0;
        require(loopcondition > 0);
         /**
             * @notice invariant forall (uint j) (j >= i || j < 0 ) || (values0[j] == rvariable)
             * @notice invariant !(i == loopcondition) || (values0[i-1] == rvariable)
             * @notice invariant forall (uint j) _auditSelectors0[j] == __verifier_old_address(_auditSelectors0[j])
             * @notice invariant forall (address a) exists (uint j) (j < loopcondition) || (values0[j] == __verifier_old_bool(values0[j]))
             */
  for (i = initial; i < loopcondition; i++) {
    values0[i] = rvariable;
   }
  }
}