contract ETHGainBefore {
    
    struct UserStruct {
        bool isExist;
        address wallet;
        uint referrerID;
        uint introducerID;
        address[] referral;
        mapping (uint => bool) starActive;
    }

    mapping (uint => UserStruct) public users;

    address[] referrals;
    uint _userID;
    bool noFreeReferrer;
    address freeReferrer;

    /**
     * @notice modifies ETHGainBefore.address_status
     * @notice postcondition forall (uint i) !(0 <= i && i < 16) || (users[_userID].starActive[i] == true)
     * @notice postcondition forall (address a) exists (uint j) (j < 16) || (users[_userID].starActive[i] == __verifier_old_bool(users[_userID].starActive[i]))
     */
    function setUserData() public {
        uint i = 0;
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (users[_userID].starActive[i] == true)
         * @notice invariant !(i == 16) || (users[_userID].starActive[i-1] == true)
         * @notice invariant forall (address a) exists (uint j) (j < 16) || (users[_userID].starActive[i] == __verifier_old_bool(users[_userID].starActive[i]))
         */
       for(i = 1; i <= 16; i++){
            users[_userID].starActive[i] = true;
        }

    }

    /**
     * @notice modifies ETHGainBefore.noFreeReferrer
     * @notice postcondition forall (uint i) !(0 <= i && i < 363) || (noFreeReferrer == false)
     * @notice postcondition forall (address a) exists (uint j) (j < 363) || (noFreeReferrer == __verifier_old_bool(noFreeReferrer))
     */
    function findFreeReferrer() public{
        uint i = 0;
   /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (noFreeReferrer == false)
         * @notice invariant !(i == 363) || (noFreeReferrer == false)
         * @notice invariant forall (address a) exists (uint j) (j < 363) || (noFreeReferrer == __verifier_old_bool(noFreeReferrer))
         */
        for(i = 0; i < 363; i++){
            noFreeReferrer = false;
        }

    }

    /**
     * @notice modifies ETHGainBefore.freeReferrer
     * @notice postcondition forall (uint i) !(0 <= i && i < 363) || (freeReferrer == referrals[i])
     * @notice postcondition forall (address a) exists (uint j) (j < 363) || (freeReferrer == __verifier_old_address(noFreeReferrer))
     */
    function findFreeReferrer2()  public{
        uint i = 0;
   /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (freeReferrer == referrals[i])
         * @notice invariant !(i == 363) || (freeReferrer == referrals[i])
         * @notice invariant forall (address a) exists (uint j) (j < 363) || (freeReferrer == __verifier_old_address(noFreeReferrer))
         */
        for(uint i = 0; i < 363; i++){
            freeReferrer = referrals[i];
        }

    }
}