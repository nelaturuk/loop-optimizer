contract SuperFairAfter {

    struct Order0 {
        address user;
        uint256 amount;
        string inviteCode;
        string referrer;
        bool execute;
    }


    uint256 rid = 1;
    mapping(uint256 => mapping(uint256 => Order0)) public waitOrder0;
    uint256 public startNum0 = 1;
    uint256 public end0;

    /**
     * @notice modifies SuperFairAfter.waitOrder0
     * @notice postcondition forall (uint i) !(startNum0 <= i && i < startNum0 + end0) || (waitOrder0[rid][i].execute == true)
     * @notice postcondition startNum0 + end0 == __verifier_old_uint(startNum0 + end0)
     * @notice postcondition exists (uint j) (j < startNum0 + end0) || (waitOrder0[rid][j].execute == __verifier_old_bool(waitOrder0[rid][j].execute))
     */
    function executeLine0() public {
        bool rvariable = true;
        uint256 initial = startNum0;
        uint256 loopcondition = startNum0 + end0;
        executeLine_for(rvariable, initial, loopcondition);
    }

    /**
     * @notice modifies SuperFairAfter.waitOrder0
     * @notice postcondition forall (uint i) !(initial <= i && i < loopcondition) || (waitOrder0[rid][i].execute == rvariable)
     * @notice postcondition loopcondition == __verifier_old_uint(loopcondition)
     * @notice postcondition exists (uint j) (j < loopcondition) || (waitOrder0[rid][j].execute == __verifier_old_bool(waitOrder0[rid][j].execute))
     */
    function executeLine_for(
        bool rvariable,
        uint256 initial,
        uint256 loopcondition
    ) internal {
        uint256 i = 0;
        require(loopcondition > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < initial ) || (waitOrder0[rid][j].execute == rvariable)
         * @notice invariant exists (uint j) (j < loopcondition) || (waitOrder0[rid][j].execute == __verifier_old_bool(waitOrder0[rid][j].execute))
         */
        for (i = initial; i < loopcondition; i++) {
            waitOrder0[rid][i].execute = rvariable;
        }
    }
}
