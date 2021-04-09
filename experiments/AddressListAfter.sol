contract AddressListAfter {
    mapping(address => bool) public address_status0;
    address[] public addresses0;

    /**
     * @notice modifies AddressListAfter.address_status0
     * @notice postcondition forall (uint i) !(0 <= i && i < addresses0.length) || (address_status0[addresses0[i]] == false)
     * @notice postcondition forall (uint j) addresses0[j] == __verifier_old_address(addresses0[j])
     * @notice postcondition addresses0.length == __verifier_old_uint(addresses0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < addresses0.length && a == addresses0[j]) || (address_status0[a] == __verifier_old_bool(address_status0[a]))
     */
    function _reset0() public {
        bool rvariable = false;
        uint256 loopcondition = addresses0.length;
        _reset_for(rvariable, loopcondition);
    }

    /**
     * @notice modifies AddressListAfter.address_status0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (address_status0[addresses0[i]] == rvariable)
     * @notice postcondition forall (uint j) addresses0[j] == __verifier_old_address(addresses0[j])
     * @notice postcondition addresses0.length == __verifier_old_uint(addresses0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && a == addresses0[j]) || (address_status0[a] == __verifier_old_bool(address_status0[a]))
     */
    function _reset_for(bool rvariable, uint256 loopcondition) internal {
        uint256 i = 0;
        require(loopcondition > 0);
         /**
             * @notice invariant forall (uint j) (j >= i || j < 0 ) || (address_status0[addresses0[j]] == rvariable)
             * @notice invariant !(i == loopcondition) || (address_status0[addresses0[i-1]] == rvariable)
             * @notice invariant forall (uint j) addresses0[j] == __verifier_old_address(addresses0[j])
             * @notice invariant forall (address a) exists (uint j) (j < loopcondition && a == addresses0[j]) || (address_status0[a] == __verifier_old_bool(address_status0[a]))
             */
        for (i = 0; i < loopcondition; i++) {
            address_status0[addresses0[i]] = rvariable;
        }
    }
}
