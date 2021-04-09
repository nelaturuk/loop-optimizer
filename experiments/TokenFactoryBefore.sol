contract TokenFactoryBefore {

  address[] public _auditSelectors;
  bool[] public values;


  /**
   * @dev reviewToken
   */
   /**
     * @notice modifies TokenFactoryBefore.values
     * @notice postcondition forall (uint i) !(0 <= i && i < _auditSelectors.length) || (values[i] == true)
     * @notice postcondition _auditSelectors.length == __verifier_old_uint(_auditSelectors.length)
     * @notice postcondition forall (uint i) _auditSelectors[i] == __verifier_old_address(_auditSelectors[i])
     * @notice postcondition forall (address a) exists (uint j) (j < _auditSelectors.length) || (values[j] == __verifier_old_bool(values[j]))
     */
  function reviewToken()
    public 
  {
     uint i = 0;
    require(_auditSelectors.length > 0);
   /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (values[j] == true)
         * @notice invariant !(i == _auditSelectors.length) || (values[i-1] == true)
         * @notice invariant forall (uint j) _auditSelectors[j] == __verifier_old_address(_auditSelectors[j])
         * @notice invariant forall (address a) exists (uint j) (j < _auditSelectors.length) || (values[j] == __verifier_old_bool(values[j]))
         */
    for(i=0; i < _auditSelectors.length; i++) {
      values[i] = true;
    }
  }
}