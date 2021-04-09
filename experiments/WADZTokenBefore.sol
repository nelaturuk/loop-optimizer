contract WADZTokenBefore {
   
    mapping(address => bool) public admins;
    mapping(address => bool) public whitelist;
    address[] public _addresses;
   
   /**
     * @notice modifies WADZTokenBefore.admins
     * @notice postcondition forall (uint i) !(0 <= i && i < _addresses.length) || (admins[_addresses[i]] == true)
     * @notice postcondition _addresses.length == __verifier_old_uint(_addresses.length)
     * @notice postcondition forall (uint i) _addresses[i] == __verifier_old_address(_addresses[i])
     * @notice postcondition forall (address a) exists (uint j) (j < _addresses.length && a == _addresses[j]) || (admins[a] == __verifier_old_bool(admins[a]))
     */
    function setAdministrators() public {
        uint i = 0;
        require(_addresses.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (admins[_addresses[j]] == true)
         * @notice invariant !(i == _addresses.length) || (admins[_addresses[i-1]] == true)
         * @notice invariant forall (uint j) _addresses[j] == __verifier_old_address(_addresses[j])
         * @notice invariant forall (address a) exists (uint j) (j < _addresses.length && a == _addresses[j]) || (admins[a] == __verifier_old_bool(admins[a]))
         */
        for(i=0; i < _addresses.length; i++) {
            admins[_addresses[i]] = true;
        }
    }
   
   /**
     * @notice modifies WADZTokenBefore.whitelist
     * @notice postcondition forall (uint i) !(0 <= i && i < _addresses.length) || (whitelist[_addresses[i]] == true)
     * @notice postcondition _addresses.length == __verifier_old_uint(_addresses.length)
     * @notice postcondition forall (uint i) _addresses[i] == __verifier_old_address(_addresses[i])
     * @notice postcondition forall (address a) exists (uint j) (j < _addresses.length && a == _addresses[j]) || (whitelist[a] == __verifier_old_bool(whitelist[a]))
     */
    function whitelist_addresses() public {
        uint i = 0;
        require(_addresses.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (whitelist[_addresses[j]] == true)
         * @notice invariant !(i == _addresses.length) || (whitelist[_addresses[i-1]] == true)
         * @notice invariant forall (uint j) _addresses[j] == __verifier_old_address(_addresses[j])
         * @notice invariant forall (address a) exists (uint j) (j < _addresses.length && a == _addresses[j]) || (whitelist[a] == __verifier_old_bool(whitelist[a]))
         */
        for(i=0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = true;
        }
    }
}