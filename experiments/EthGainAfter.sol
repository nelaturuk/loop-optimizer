contract ETHGainAfter {
    struct UserStruct {
        bool isExist;
        address wallet;
        uint256 referrerID;
        uint256 introducerID;
        address[] referral;
        mapping(uint256 => bool) starActive;
    }

    mapping(uint256 => UserStruct) public users;
    address[] referrals;
    uint256 _userID;
    bool noFreeReferrer;
    address freeReferrer;

    /**
     * @notice modifies ETHGainBefore.address_status
     * @notice postcondition forall (uint i) !(0 <= i && i < 16) || (users[_userID].starActive[i] == true)
     * @notice postcondition forall (address a) exists (uint j) (j < 16) || (users[_userID].starActive[i] == __verifier_old_bool(users[_userID].starActive[i]))
     */
    function setUserData0() public {
        bool rvariable = true;
        uint256 initial = 1;
        uint256 loopcondition = 16;
        setUserData_for(rvariable, initial, loopcondition);
    }

    function setUserData_for(
        bool rvariable,
        uint256 initial,
        uint256 loopcondition
    ) internal {
        uint i = 0;
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (users[_userID].starActive[i] == true)
         * @notice invariant !(i == 16) || (users[_userID].starActive[i-1] == true)
         * @notice invariant forall (address a) exists (uint j) (j < 16) || (users[_userID].starActive[i] == __verifier_old_bool(users[_userID].starActive[i]))
         */
        for (uint256 i = initial; i <= loopcondition; i++) {
            users[_userID].starActive[i] = rvariable;
        }
    }

    /**
     * @notice modifies ETHGainBefore.noFreeReferrer
     * @notice postcondition forall (uint i) !(0 <= i && i < 363) || (noFreeReferrer == false)
     * @notice postcondition forall (address a) exists (uint j) (j < 363) || (noFreeReferrer == __verifier_old_bool(noFreeReferrer))
     */
    function findFreeReferrer0() public {
        bool rvariable = false;
        uint256 initial = 0;
        uint256 loopcondition = 363;
        findFreeReferrer_for(rvariable, initial, loopcondition);
    }

    function findFreeReferrer_for(
        bool rvariable,
        uint256 initial,
        uint256 loopcondition
    ) internal {
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (noFreeReferrer == false)
         * @notice invariant !(i == 363) || (noFreeReferrer == false)
         * @notice invariant forall (address a) exists (uint j) (j < 363) || (noFreeReferrer == __verifier_old_bool(noFreeReferrer))
         */
        for (uint256 i = initial; i <= loopcondition; i++) {
            noFreeReferrer = rvariable;
        }
    }

    /**
     * @notice modifies ETHGainBefore.freeReferrer
     * @notice postcondition forall (uint i) !(0 <= i && i < 363) || (freeReferrer == referrals[i])
     * @notice postcondition forall (address a) exists (uint j) (j < 363) || (freeReferrer == __verifier_old_address(noFreeReferrer))
     */
    function findFreeReferrer20() public {
        bool rvariable = false;
        uint256 initial = 0;
        uint256 loopcondition = 363;
        findFreeReferrer2_for(rvariable, initial, loopcondition);
    }

    function findFreeReferrer2_for(
        bool rvariable,
        uint256 initial,
        uint256 loopcondition
    ) internal {
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (freeReferrer == referrals[i])
         * @notice invariant !(i == 363) || (freeReferrer == referrals[i])
         * @notice invariant forall (address a) exists (uint j) (j < 363) || (freeReferrer == __verifier_old_address(noFreeReferrer))
         */
        for (uint256 i = initial; i <= loopcondition; i++) {
            freeReferrer = referrals[i];
        }
    }
}
