contract MetalAirdropBefore {
    mapping(address => bool) public airdrops;
    address[] public _recipient;

    /**
     * @notice modifies MetalAirdropBefore.airdrops
     * @notice postcondition forall (uint i) !(0 <= i && i < _recipient.length && !airdrops[_recipient[i]]) || (airdrops[_recipient[i]] == true)
     * @notice postcondition _recipient.length == __verifier_old_uint(_recipient.length)
     * @notice postcondition forall (uint i) _recipient[i] == __verifier_old_address(_recipient[i])
     * @notice postcondition forall (address a) exists (uint j) (j < _recipient.length && a == _recipient[j] && !airdrops[a]) || (airdrops[a] == __verifier_old_bool(airdrops[a]))
     */
    function airdropTokens() public {
        uint256 i = 0;
        require(_recipient.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (airdrops[_recipient[j]] == true) || (airdrops[_recipient[j]] == __verifier_old_bool(airdrops[_recipient[j]]))
         * @notice invariant !(i == _recipient.length && !airdrops[_recipient[i-1]]) || (airdrops[_recipient[i-1]] == true) 
         * @notice invariant forall (uint j) _recipient[j] == __verifier_old_address(_recipient[j])
         * @notice invariant forall (address a) exists (uint j) (j < _recipient.length && a == _recipient[j] && !airdrops[a]) || (airdrops[a] == __verifier_old_bool(airdrops[a]))
         */
        for (i = 0; i < _recipient.length; i++) {
            if (!airdrops[_recipient[i]]) {
                airdrops[_recipient[i]] = true;
            }
        }
    }
}
