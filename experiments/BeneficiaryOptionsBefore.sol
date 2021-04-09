contract BeneficiaryOptionsBefore {

    uint256 public beneficiariesGeneration;
    uint256 public howManyBeneficiariesDecide;
    address[] public beneficiaries;
    bytes32[] public allOperations;
    address internal insideCallSender;
    uint256 internal insideCallCount;
    

    // Reverse lookup tables for beneficiaries and allOperations
    mapping(address => uint256) public beneficiariesIndices; // Starts from 1, size 255
    mapping(bytes32 => uint) public allOperationsIndicies;
    

    // beneficiaries voting mask per operations
    mapping(bytes32 => uint256) public votesMaskByOperation;
    mapping(bytes32 => uint256) public votesCountByOperation;

    //operation -> beneficiaryIndex
    mapping(bytes32 => uint256) public  operationsByBeneficiaryIndex;
    mapping(uint256 => uint256) public operationsCountByBeneficiaryIndex;
    address[] public newBeneficiaries;

    // EVENTS
     /**
     * @notice modifies BeneficiaryOptionsBefore.operationsCountByBeneficiaryIndex
     * @notice postcondition forall (uint j) !(0 <= j && j < beneficiaries.length) || (operationsCountByBeneficiaryIndex[j] == 0)
     * @notice postcondition beneficiaries.length == __verifier_old_uint(beneficiaries.length)
     * @notice postcondition forall (uint j) beneficiaries[j] == __verifier_old_address(beneficiaries[j])
     * @notice postcondition forall (address a) exists (uint j) (j < beneficiaries.length) || (operationsCountByBeneficiaryIndex[j] == __verifier_old_uint(operationsCountByBeneficiaryIndex[j]))
     */
    function _cancelAllPending() public {
         uint8 j = 0;
        require(beneficiaries.length > 0);
   /**
         * @notice invariant forall (uint i) (i >= j || i < 0 ) || (operationsCountByBeneficiaryIndex[i] == 0)
         * @notice invariant !(j == beneficiaries.length) || (operationsCountByBeneficiaryIndex[j-1] == 0)
         * @notice invariant forall (uint i) beneficiaries[i] == __verifier_old_address(beneficiaries[i])
         * @notice invariant forall (address a) exists (uint i) (i < beneficiaries.length) || (operationsCountByBeneficiaryIndex[i] == __verifier_old_uint(operationsCountByBeneficiaryIndex[i]))
         */
        for (j = 0; j < beneficiaries.length; j++) {
            operationsCountByBeneficiaryIndex[j] = 0;
        }
    }

    /**
     * @notice modifies BeneficiaryOptionsBefore.beneficiariesIndices
     * @notice postcondition newBeneficiaries.length == __verifier_old_uint(newBeneficiaries.length)
     * @notice postcondition forall (uint i) newBeneficiaries[i] == __verifier_old_address(newBeneficiaries[i])
     * @notice postcondition forall (address a) exists (uint j) (j < newBeneficiaries.length && a == newBeneficiaries[j]) || (beneficiariesIndices[a] == __verifier_old_uint(beneficiariesIndices[a]))
     */
    function transferBeneficiaryShipWithHowMany() public {
         uint256 i = 0;
         require(newBeneficiaries.length > 0);
        /**
         * @notice invariant !(i == newBeneficiaries.length) || (beneficiariesIndices[newBeneficiaries[i-1]] == i)
         * @notice invariant forall (uint j) newBeneficiaries[j] == __verifier_old_address(newBeneficiaries[j])
         * @notice invariant forall (address a) exists (uint j) (j < newBeneficiaries.length && a == newBeneficiaries[j]) || (beneficiariesIndices[a] == __verifier_old_uint(beneficiariesIndices[a]))
         */
        for (i = 0; i < newBeneficiaries.length; i++) {
            beneficiariesIndices[newBeneficiaries[i]] = i + 1;
        }
    }
}
