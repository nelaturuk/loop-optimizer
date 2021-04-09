
contract PlayIQuizAfter {
    mapping(bytes32 => bool) public admin0;
    bytes32[] public admins0;

    /**
     * @notice modifies PlayIQuizAfter.admin0
     * @notice postcondition forall (uint i) !(0 <= i && i < admins0.length) || (admin0[admins0[i]] == true)
     * @notice postcondition admins0.length == __verifier_old_uint(admins0.length)
     * @notice postcondition forall (bytes32 a) exists (uint j) (j < admins0.length && a == admins0[j]) || (admin0[a] == __verifier_old_bool(admin0[a]))
     */
    function initAdmins0() public {
        bool rvariable = true;
        uint256 initial = 0;
        uint256 loopcondition = admins0.length;
        initAdmins_for(rvariable, initial, loopcondition);
    }

    /**
     * @notice modifies PlayIQuizAfter.admin0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (admin0[admins0[i]] == true)
     * @notice postcondition loopcondition == __verifier_old_uint(loopcondition)
     * @notice postcondition forall (bytes32 a) exists (uint j) (j < loopcondition && a == admins0[j]) || (admin0[a] == __verifier_old_bool(admin0[a]))
     */
    function initAdmins_for(
        bool rvariable,
        uint256 initial,
        uint256 loopcondition
    ) internal {
        uint256 i = 0;
        require(admins0.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (admin0[admins0[j]] == true)
         * @notice invariant !(i == loopcondition) || (admin0[admins0[i-1]] == true)
         * @notice invariant forall (bytes32 a) exists (uint j) (j < loopcondition && a == admins0[j]) || (admin0[a] == __verifier_old_bool(admin0[a]))
         */
        for (i = initial; i < loopcondition; i++) {
            admin0[admins0[i]] = rvariable;
        }
    }
}
