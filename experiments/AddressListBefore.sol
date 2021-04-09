contract AddressListBefore{
//   using AddressArray for address[];
  mapping(address => bool) public address_status;
  address[] public addresses;

  
    /**
     * @notice modifies AddressListBefore.address_status
     * @notice postcondition forall (uint i) !(0 <= i && i < addresses.length) || (address_status[addresses[i]] == false)
     * @notice postcondition addresses.length == __verifier_old_uint(addresses.length)
     * @notice postcondition forall (uint i) addresses[i] == __verifier_old_address(addresses[i])
     * @notice postcondition forall (address a) exists (uint j) (j < addresses.length && a == addresses[j]) || (address_status[a] == __verifier_old_bool(address_status[a]))
     */
  function _reset() public{
    uint i = 0;
    require(addresses.length > 0);
   /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (address_status[addresses[j]] == false)
         * @notice invariant !(i == addresses.length) || (address_status[addresses[i-1]] == false)
         * @notice invariant forall (uint j) addresses[j] == __verifier_old_address(addresses[j])
         * @notice invariant forall (address a) exists (uint j) (j < addresses.length && a == addresses[j]) || (address_status[a] == __verifier_old_bool(address_status[a]))
         */
    for(i = 0; i < addresses.length; i++){
      address_status[addresses[i]] = false;
    }
  }
}