pragma solidity ^0.5.10;

contract MyContract {

  mapping(uint256 => uint32[7]) gameStats;
  mapping(uint256 => uint256) weiRaised;
  mapping(uint8 => uint8) percents;
  uint256 public jackpot;

  /*
    INDEX: _game, i
    GUARD: i
    WRITTEN: jackpot, i
    READ: jackpot, i, weiRaised, _game, percents, gameStats
    jackpot' <-- i, weiRaised, _game, percents
    i'       <-- i
   */
  function foo(uint256 _game) public returns (uint256) {
    jackpot = 0;    
    for (uint8 i = 1; i <= 5; i ++) {
      if (gameStats[_game][i] == 0) {
	jackpot += (weiRaised[_game]*percents[i])/100;
      }
    }
    return jackpot;
  }
  
    
}
