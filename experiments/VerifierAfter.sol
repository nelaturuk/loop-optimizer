contract VerifierAfter { 
    uint[] public input0;
    uint[] public inputValues0;

    /**
  * @notice modifies VerifierAfter.inputValues0
  * @notice postcondition forall (uint i) !(0 <= i && i < input0.length) || (inputValues0[i] == input0[i])
  * @notice postcondition input0.length == __verifier_old_uint(input0.length)
  * @notice postcondition forall (uint i) input0[i] == __verifier_old_uint(input0[i])
  * @notice postcondition forall (address a) exists (uint j) (j < input0.length && (inputValues0[j] == input0[j])) || (inputValues0[j] == __verifier_old_uint(inputValues0[j]))
  */ 
    function verifyProof0() public {
    uint initial = 0;
    uint mapstart = 0;
    uint mapend = 0;
    uint loopcondition = input0.length;
    verifyProof_for(initial, loopcondition, mapstart, mapend);
  }

   /**
  * @notice modifies VerifierAfter.inputValues0
  * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (inputValues0[i] == input0[i])
  * @notice postcondition loopcondition == __verifier_old_uint(loopcondition)
  * @notice postcondition forall (uint i) input0[i] == __verifier_old_uint(input0[i])
  * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && (inputValues0[j] == input0[j])) || (inputValues0[j] == __verifier_old_uint(inputValues0[j]))
  */ 
  function verifyProof_for(uint initial, uint loopcondition, uint _mapstart, uint _mapend) internal {
    uint i = 0;
    require(loopcondition > 0);
    /**
    * @notice invariant forall (uint j) (j >= i || j < 0 ) || (inputValues0[j] == input0[j])
    * @notice invariant forall (uint i) input0[i] == __verifier_old_uint(input0[i])
    * @notice invariant forall (address a) exists (uint j) (j < loopcondition && (inputValues0[j] == input0[j])) || (inputValues0[j] == __verifier_old_uint(inputValues0[j]))
    */
  for (i = initial; i < loopcondition; ++i) {
          inputValues0[i + _mapstart] = input0[i + _mapend];
    }
  }
 
}