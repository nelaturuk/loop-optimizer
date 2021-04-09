contract FutureAfter { 
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
     * @notice modifies FutureAfter.amount
     * @notice postcondition amount >= __verifier_old_uint(amount)
     * @notice postcondition amount == __verifier_old_uint(amount) + __verifier_sum_uint(luckyAmounts)
     */
    function querySafety() public {
    uint initial = 0;
    uint initialSum = amount; 
    uint loopcondition = luckyAmounts.length;
    amount = querySafety_for(initial, initialSum, loopcondition);
  }

  /**
     * @notice postcondition temp_total >= __verifier_old_uint(temp_total)
     * @notice postcondition loopcondition != luckyAmounts.length || initial != 0 || val == initialSum + __verifier_sum_uint(luckyAmounts)
     */
  function querySafety_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    /**
         * @notice invariant temp_total >= __verifier_old_uint(temp_total)
         * @notice invariant temp_total == __verifier_old_uint(temp_total) + sum(luckyAmounts[0] ... luckyAmounts[i])
         */
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + investments[i];
    }
    return temp_total;
  }  

  /**
     * @notice modifies FutureAfter.totalRandom
     * @notice postcondition totalRandom >= __verifier_old_uint(totalRandom)
     * @notice postcondition totalRandom == __verifier_old_uint(totalRandom) + __verifier_sum_uint(luckyAmounts)
     */
    function lottery2() public {
    uint initial = 0;
    uint initialSum = totalRandom; 
    uint loopcondition = luckyAmounts.length;
    totalRandom = lottery2_for(initial, initialSum, loopcondition);
  }

  /**
     * @notice postcondition temp_total >= __verifier_old_uint(temp_total)
     * @notice postcondition loopcondition != luckyAmounts.length || initial != 0 || val == initialSum + __verifier_sum_uint(luckyAmounts)
     */
  function lottery2_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    /**
         * @notice invariant temp_total >= __verifier_old_uint(temp_total)
         * @notice invariant temp_total == __verifier_old_uint(temp_total) + sum(luckyAmounts[0] ... luckyAmounts[i])
         */
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + luckyAmounts[i];
    }
    return temp_total;
  }  
function lottery() public {        if (dailyPlayers.length <= 10) {
    uint initial = 0;
    uint mapstart = 0;
    uint mapend = 0;
    uint loopcondition = dailyPlayers.length;
    lottery_for(initial, loopcondition, mapstart, mapend);
  }
  } 
 function lottery_for(uint initial, uint loopcondition, uint _mapstart, uint _mapend) internal {
  for (uint i = initial; i < loopcondition; ++i) {
          luckyDogs[i + _mapstart] = dailyPlayers[i + _mapend];
    }
  }
  /**
     * @notice modifies FutureAfter.randTotal
     * @notice postcondition randTotal >= __verifier_old_uint(randTotal)
     * @notice postcondition randTotal == __verifier_old_uint(randTotal) + __verifier_sum_uint(lockedRound)
     */
    function calcLocked() public {
    uint initial = 0;
    uint initialSum = randTotal; 
    uint loopcondition = lockedRound.length;
    randTotal = calcLocked_for(initial, initialSum, loopcondition);
  }

  /**
     * @notice postcondition temp_total >= __verifier_old_uint(temp_total)
     * @notice postcondition loopcondition != lockedRound.length || initial != 0 || val == initialSum + __verifier_sum_uint(lockedRound)
     */
  function calcLocked_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    /**
         * @notice invariant temp_total >= __verifier_old_uint(temp_total)
         * @notice invariant temp_total == __verifier_old_uint(temp_total) + sum(lockedRound[0] ... lockedRound[i])
         */
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + lockedRound[i];
    }
    return temp_total;
  }  
 
}