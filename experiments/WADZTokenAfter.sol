contract WADZTokenAfter { 
    mapping(address => bool) public admins0;
    mapping(address => bool) public whitelist0;
    address[] public _addresses0;

    /**
     * @notice modifies WADZTokenAfter.admins0
     * @notice postcondition forall (uint i) !(0 <= i && i < _addresses0.length) || (admins0[_addresses0[i]] == true)
     * @notice postcondition forall (uint j) _addresses0[j] == __verifier_old_address(_addresses0[j])
     * @notice postcondition _addresses0.length == __verifier_old_uint(_addresses0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < _addresses0.length && a == _addresses0[j]) || (admins0[a] == __verifier_old_bool(admins0[a]))
     */
  function setAdministrators0() public {
    bool rvariable = true; 
    uint loopcondition = _addresses0.length;
    setAdministrators_for(rvariable, loopcondition);
  }

  /**
     * @notice modifies WADZTokenAfter.admins0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (admins0[_addresses0[i]] == rvariable)
     * @notice postcondition forall (uint j) _addresses0[j] == __verifier_old_address(_addresses0[j])
     * @notice postcondition _addresses0.length == __verifier_old_uint(_addresses0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && a == _addresses0[j]) || (admins0[a] == __verifier_old_bool(admins0[a]))
     */
  function setAdministrators_for(bool rvariable, uint loopcondition) internal {
    uint256 i = 0;
        require(loopcondition > 0);
         /**
             * @notice invariant forall (uint j) (j >= i || j < 0 ) || (admins0[_addresses0[j]] == rvariable)
             * @notice invariant !(i == loopcondition) || (admins0[_addresses0[i-1]] == rvariable)
             * @notice invariant forall (uint j) _addresses0[j] == __verifier_old_address(_addresses0[j])
             * @notice invariant forall (address a) exists (uint j) (j < loopcondition && a == _addresses0[j]) || (admins0[a] == __verifier_old_bool(admins0[a]))
             */
  for (i = 0; i < loopcondition; i++) {
    admins0[_addresses0[i]] = rvariable;
   }
  }

  /**
     * @notice modifies WADZTokenAfter.whitelist0
     * @notice postcondition forall (uint i) !(0 <= i && i < _addresses0.length) || (whitelist0[_addresses0[i]] == true)
     * @notice postcondition forall (uint j) _addresses0[j] == __verifier_old_address(_addresses0[j])
     * @notice postcondition _addresses0.length == __verifier_old_uint(_addresses0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < _addresses0.length && a == _addresses0[j]) || (whitelist0[a] == __verifier_old_bool(whitelist0[a]))
     */
  function whitelist0Addresses0() public {
    bool rvariable = true; 
    uint loopcondition = _addresses0.length;
    whitelist0Addresses_for(rvariable, loopcondition);
  }

  /**
     * @notice modifies WADZTokenAfter.whitelist0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (whitelist0[_addresses0[i]] == rvariable)
     * @notice postcondition forall (uint j) _addresses0[j] == __verifier_old_address(_addresses0[j])
     * @notice postcondition _addresses0.length == __verifier_old_uint(_addresses0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && a == _addresses0[j]) || (whitelist0[a] == __verifier_old_bool(whitelist0[a]))
     */
  function whitelist0Addresses_for(bool rvariable, uint loopcondition) internal {

    uint256 i = 0;
        require(loopcondition > 0);
         /**
             * @notice invariant forall (uint j) (j >= i || j < 0 ) || (whitelist0[_addresses0[j]] == rvariable)
             * @notice invariant !(i == loopcondition) || (whitelist0[_addresses0[i-1]] == rvariable)
             * @notice invariant forall (uint j) _addresses0[j] == __verifier_old_address(_addresses0[j])
             * @notice invariant forall (address a) exists (uint j) (j < loopcondition && a == _addresses0[j]) || (whitelist0[a] == __verifier_old_bool(whitelist0[a]))
             */
  for (i = 0; i < loopcondition; i++) {
    whitelist0[_addresses0[i]] = rvariable;
   }
  }
 
}