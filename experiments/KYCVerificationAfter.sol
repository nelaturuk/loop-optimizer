contract KYCVerificationAfter {
    mapping(address => bool) public kycAddress0;
    bool public _status0;
    address[] public _kycAddress0;

    /**
     * @notice modifies KYCVerificationAfter.kycAddress0
     * @notice postcondition forall (uint i) !(0 <= i && i < _kycAddress0.length) || (kycAddress0[_kycAddress0[i]] == _status0)
     * @notice postcondition forall (uint j) _kycAddress0[j] == __verifier_old_address(_kycAddress0[j])
     * @notice postcondition _kycAddress0.length == __verifier_old_uint(_kycAddress0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < _kycAddress0.length && a == _kycAddress0[j]) || (kycAddress0[a] == __verifier_old_bool(kycAddress0[a]))
     */
    function updateVerifcationBatch0() public {
        bool rvariable = _status0;
        uint256 loopcondition = _kycAddress0.length;
        updateVerifcationBatch_for(rvariable, loopcondition);
    }

    /**
     * @notice modifies KYCVerificationAfter.kycAddress0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (kycAddress0[_kycAddress0[i]] == rvariable)
     * @notice postcondition forall (uint j) _kycAddress0[j] == __verifier_old_address(_kycAddress0[j])
     * @notice postcondition _kycAddress0.length == __verifier_old_uint(_kycAddress0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && a == _kycAddress0[j]) || (kycAddress0[a] == __verifier_old_bool(kycAddress0[a]))
     */
    function updateVerifcationBatch_for(bool rvariable, uint256 loopcondition)
        internal
    {
        uint256 i = 0;
        require(loopcondition > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (kycAddress0[_kycAddress0[j]] == rvariable)
         * @notice invariant !(i == loopcondition) || (kycAddress0[_kycAddress0[i-1]] == rvariable)
         * @notice invariant forall (uint j) _kycAddress0[j] == __verifier_old_address(_kycAddress0[j])
         * @notice invariant forall (address a) exists (uint j) (j < loopcondition && a == _kycAddress0[j]) || (kycAddress0[a] == __verifier_old_bool(kycAddress0[a]))
         */
        for (i = 0; i < loopcondition; i++) {
            kycAddress0[_kycAddress0[i]] = rvariable;
        }
    }
}
