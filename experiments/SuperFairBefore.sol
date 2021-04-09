contract SuperFairBefore {

    struct Order {
        address user;
        uint256 amount;
        string inviteCode;
        string referrer;
        bool execute;
    }

    uint256 rid = 1;
    mapping(uint256 => mapping(uint256 => Order)) public waitOrder;
    uint256 public numOrder = 1;
    uint256 public startNum = 1;
    uint256 end;

    /**
     * @notice modifies SuperFairBefore.waitOrder
     * @notice postcondition forall (uint i) !(startNum <= i && i < startNum + end) || (waitOrder[rid][i].execute == true)
     * @notice postcondition startNum + end == __verifier_old_uint(startNum + end)
     * @notice postcondition exists (uint j) (j < startNum + end) || (waitOrder[rid][j].execute == __verifier_old_bool(waitOrder[rid][j].execute))
     */
    function executeLine() public {
        uint256 i = 0;
        require(startNum + end > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < startNum ) || (waitOrder[rid][j].execute == true)
         * @notice invariant exists (uint j) (j < startNum + end) || (waitOrder[rid][j].execute == __verifier_old_bool(waitOrder[rid][j].execute))
         */
        for (i = startNum; i < startNum + end; i++) {
            waitOrder[rid][i].execute = true;
        }
    }
}
