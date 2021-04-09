contract VerifierBefore {
    
    uint[] public input;
    uint[] public inputValues;
    
    /**
        * @notice modifies VerifierBefore.inputValues
        * @notice postcondition forall (uint i) !(0 <= i && i < input.length) || (inputValues[i] == input[i])
        * @notice postcondition input.length == __verifier_old_uint(input.length)
        * @notice postcondition forall (uint i) input[i] == __verifier_old_uint(input[i])
        * @notice postcondition forall (address a) exists (uint j) (j < input.length && (inputValues[j] == input[j])) || (inputValues[j] == __verifier_old_uint(inputValues[j]))
        */  
    function verifyProof() public {
        uint i = 0;
            require(input.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (inputValues[j] == input[j])
         * @notice invariant forall (uint i) input[i] == __verifier_old_uint(input[i])
         * @notice invariant forall (address a) exists (uint j) (j < input.length && (inputValues[j] == input[j])) || (inputValues[j] == __verifier_old_uint(inputValues[j]))
         */
        for(i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
    }
}