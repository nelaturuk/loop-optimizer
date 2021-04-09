contract BeneficiaryOptionsAfter { 
    uint256 public beneficiariesGeneration0;
    uint256 public howManyBeneficiariesDecide0;
    address[] public beneficiaries0;
    bytes32[] public allOperations0;
    address internal insideCallSender0;
    uint256 internal insideCallCount0;
    mapping(address => uint256) public beneficiariesIndices0; // Starts from 1, size 255
    mapping(bytes32 => uint) public allOperationsIndicies0;
    mapping(bytes32 => uint256) public votesMaskByOperation0;
    mapping(bytes32 => uint256) public votesCountByOperation0;
    mapping(bytes32 => uint256) public  operationsByBeneficiaryIndex0;
    mapping(uint256 => uint256) public operationsCountByBeneficiaryIndex0;
    address[] public newBeneficiaries0;

    /**
     * @notice modifies BeneficiaryOptionsAfter.operationsCountByBeneficiaryIndex0
     * @notice postcondition forall (uint i) !(0 <= i && i < beneficiaries0.length) || (operationsCountByBeneficiaryIndex0[i] == 0)
     * @notice postcondition forall (uint j) beneficiaries0[j] == __verifier_old_address(beneficiaries0[j])
     * @notice postcondition beneficiaries0.length == __verifier_old_uint(beneficiaries0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < beneficiaries0.length)|| (operationsCountByBeneficiaryIndex0[j] == __verifier_old_uint(operationsCountByBeneficiaryIndex0[j]))
     */
    function _cancelAllPending0() public {
    uint rvariable = 0; 
    uint initial = 0;
    uint loopcondition = beneficiaries0.length;
    _cancelAllPending_for(rvariable, initial, loopcondition);
  }

  /**
     * @notice modifies BeneficiaryOptionsAfter.operationsCountByBeneficiaryIndex0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (operationsCountByBeneficiaryIndex0[i] == rvariable)
     * @notice postcondition forall (uint j) beneficiaries0[j] == __verifier_old_address(beneficiaries0[j])
     * @notice postcondition beneficiaries0.length == __verifier_old_uint(beneficiaries0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < loopcondition) || (operationsCountByBeneficiaryIndex0[j] == __verifier_old_uint(operationsCountByBeneficiaryIndex0[j]))
     */
  function _cancelAllPending_for(uint rvariable, uint initial, uint loopcondition) internal {
    uint i = 0;
      require(loopcondition > 0);
    /**
             * @notice invariant forall (uint j) (j >= i || j < 0 ) || (operationsCountByBeneficiaryIndex0[j] == rvariable)
             * @notice invariant !(i == loopcondition) || (operationsCountByBeneficiaryIndex0[i-1] == rvariable)
             * @notice invariant forall (uint j) beneficiaries0[j] == __verifier_old_address(beneficiaries0[j])
             * @notice invariant forall (address a) exists (uint j) (j < loopcondition) || (operationsCountByBeneficiaryIndex0[j] == __verifier_old_uint(operationsCountByBeneficiaryIndex0[j]))
             */
  for (i = initial; i < loopcondition; i++) {
    operationsCountByBeneficiaryIndex0[i] = rvariable;
   }
  }


   /**
     * @notice modifies BeneficiaryOptionsAfter.beneficiariesIndices0
     * @notice postcondition forall (uint j) newBeneficiaries0[j] == __verifier_old_address(newBeneficiaries0[j])
     * @notice postcondition newBeneficiaries0.length == __verifier_old_uint(newBeneficiaries0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < newBeneficiaries0.length && a == newBeneficiaries0[j])|| (beneficiariesIndices0[a] == __verifier_old_uint(beneficiariesIndices0[a]))
     */
  function transferBeneficiaryShipWithHowMany0() public {
    uint loopcondition = newBeneficiaries0.length;
    transferBeneficiaryShipWithHowMany_for(loopcondition);
  }

  /**
     * @notice modifies BeneficiaryOptionsAfter.beneficiariesIndices0
     * @notice postcondition forall (uint j) newBeneficiaries0[j] == __verifier_old_address(newBeneficiaries0[j])
     * @notice postcondition newBeneficiaries0.length == __verifier_old_uint(newBeneficiaries0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && a == newBeneficiaries0[j]) || (beneficiariesIndices0[a] == __verifier_old_uint(beneficiariesIndices0[a]))
     */
  function transferBeneficiaryShipWithHowMany_for(uint loopcondition) internal {
     uint i = 0;
      require(loopcondition > 0);
    /**
             * @notice invariant !(i == loopcondition) || (beneficiariesIndices0[newBeneficiaries0[i-1]] == i)
             * @notice invariant forall (uint j) newBeneficiaries0[j] == __verifier_old_address(newBeneficiaries0[j])
             * @notice invariant forall (address a) exists (uint j) (j < loopcondition  && a == newBeneficiaries0[j]) || (beneficiariesIndices0[a] == __verifier_old_uint(beneficiariesIndices0[a]))
             */
  for (i = 0; i < loopcondition; i++) {
    beneficiariesIndices0[newBeneficiaries0[i]] = i + 1;
   }
  }
 
}