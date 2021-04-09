contract LitionRegistryBefore {
    address[] public validators;
    mapping(address => bool) public miningValidators;

     /**
     * @notice modifies LitionRegistryBefore.miningValidators
     * @notice postcondition forall (uint i) !(0 <= i && i < validators.length) || (miningValidators[validators[i]] == true)
     * @notice postcondition validators.length == __verifier_old_uint(validators.length)
     * @notice postcondition forall (uint i) validators[i] == __verifier_old_address(validators[i])
     * @notice postcondition forall (address a) exists (uint j) (j < validators.length && a == validators[j]) || (miningValidators[a] == __verifier_old_bool(miningValidators[a]))
     */
    function processValidatorsRewards2() public {
        uint256 i = 0;
        require(validators.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (miningValidators[validators[j]] == true)
         * @notice invariant !(i == validators.length) || (miningValidators[validators[i-1]] == true)
         * @notice invariant forall (uint j) validators[j] == __verifier_old_address(validators[j])
         * @notice invariant forall (address a) exists (uint j) (j < validators.length && a == validators[j]) || (miningValidators[a] == __verifier_old_bool(miningValidators[a]))
         */
        for(i = 0; i < validators.length; i++) {
            miningValidators[validators[i]] = true;
        }
    }
   
}