pragma solidity ^0.5.10;

contract MyContract {

  uint fromRewardIdx;
  uint toRewardIdx;
  uint updatedBalance;
  uint holding_totalTokens;
  uint [] rewards;
  
  function foo() internal returns (uint) {
   /*
     INDEX: idx
     GUARD: idx, toRewardIdx
     WRITTEN: idx, updatedBalance
     READ: rewards, updatedBalance, idx, holding_totalTokens, fromRewardIdx
     updatedBalance' <-- rewards, updatedBalance, idx, holding_totalTokens,
			 fromRewardIdx
     idx' <-- fromRewardIdx, idx			
    */    
    for(uint idx = fromRewardIdx; idx <= toRewardIdx; idx += 1) {
      updatedBalance += rewards[idx];
    }

    updatedBalance *= holding_totalTokens;
    
    return updatedBalance;
  }    
}
