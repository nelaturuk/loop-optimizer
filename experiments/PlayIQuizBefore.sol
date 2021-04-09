
contract PlayIQuizBefore
{
    mapping (bytes32=>bool) public admin;
    bytes32[] public admins;

     /**
     * @notice modifies PlayIQuizBefore.admin
     * @notice postcondition forall (uint i) !(0 <= i && i < admins.length) || (admin[admins[i]] == true)
     * @notice postcondition admins.length == __verifier_old_uint(admins.length)
     * @notice postcondition forall (bytes32 a) exists (uint j) (j < admins.length && a == admins[j]) || (admin[a] == __verifier_old_bool(admin[a]))
     */
    function initAdmins() public{
        uint i = 0;
        require(admins.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (admin[admins[j]] == true)
         * @notice invariant !(i == admins.length) || (admin[admins[i-1]] == true)
         * @notice invariant forall (bytes32 a) exists (uint j) (j < admins.length && a == admins[j]) || (admin[a] == __verifier_old_bool(admin[a]))
         */
        for(i=0; i< admins.length; i++){
            admin[admins[i]] = true;        
        }       
    }
}