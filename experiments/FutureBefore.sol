contract FutureBefore {
    uint[] public lockedRound = new uint[](0);
    uint256[] investments;
    uint investCount = 0;
    address[] public dailyPlayers = new address[](0);
    uint randTotal;
    address[] luckyDogs;
    uint[] luckyAmounts;
    uint totalRandom = 0;
    uint256 amount = 0;

    /**
     * @notice modifies FutureBefore.randTotal
     * @notice postcondition randTotal >= __verifier_old_uint(randTotal)
     * @notice postcondition randTotal == __verifier_old_uint(randTotal) + __verifier_sum_uint(lockedRound)
     */
    function calcLocked(address target) public {
        uint256 i = 0;
        require(lockedRound.length > 0);
        /**
         * @notice invariant randTotal >= __verifier_old_uint(randTotal)
         * @notice invariant randTotal == __verifier_old_uint(randTotal) + sum(lockedRound[0] ... lockedRound[i])
         */
        for(i=0; i<lockedRound.length; i++){
            randTotal = randTotal + lockedRound[i];
        }
    }

    // function lottery() internal {
    //     if (dailyPlayers.length <= 10) {
    //         for(uint i=0; i<dailyPlayers.length; i++) {
    //             luckyDogs[i] = dailyPlayers[i];
    //         }
    //     } 
    // }

    /**
     * @notice modifies FutureBefore.totalRandom
     * @notice postcondition totalRandom >= __verifier_old_uint(totalRandom)
     * @notice postcondition totalRandom == __verifier_old_uint(totalRandom) + __verifier_sum_uint(luckyAmounts)
     */
    function lottery2() {
        uint256 i = 0;
        require(luckyAmounts.length > 0);
        /**
         * @notice invariant totalRandom >= __verifier_old_uint(totalRandom)
         * @notice invariant totalRandom == __verifier_old_uint(totalRandom) + sum(luckyAmounts[0] ... luckyAmounts[i])
         */
        for(uint i=0; i<luckyAmounts.length; i++){
            totalRandom = totalRandom + luckyAmounts[i];
        }
    }

    /**
     * @notice modifies FutureBefore.amount
     * @notice postcondition amount >= __verifier_old_uint(amount)
     * @notice postcondition amount == __verifier_old_uint(amount) + __verifier_sum_uint(investments)
     */
    function querySafety() public{
        uint256 i = 0;
        require(luckyAmounts.length > 0);
        /**
         * @notice invariant amount >= __verifier_old_uint(amount)
         * @notice invariant amount == __verifier_old_uint(amount) + sum(investments[0] ... investments[i])
         */
        for (i = 0; i < luckyAmounts.length; i++){
                amount = amount + investments[i];
        }
    }
}