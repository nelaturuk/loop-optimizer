pragma solidity ^0.5.10;

contract MyContract {

  mapping(uint256 => uint32[7]) gameStats;
  mapping(uint256 => uint256) weiRaised;
  mapping(uint8 => uint8) percents;
  uint256 public jackpot;

  /* function distributeRaisedWeiToJackpot(uint256 _game) public returns (uint256) { */
  function foo(uint256 _game) public returns (uint256) {
    for (uint8 i = 1; i <= 5; i ++) {
      jackpot = 0;
      if (gameStats[_game][i] == 0) {
	/* jackpot += weiRaised[_game].mul(percents[i]).div(100); */
	/* jackpot += (weiRaised[_game]*percents[i])/100; */
	jackpot += (weiRaised[_game]*percents[i]);
      }
    }
    jackpot /= 100;
    return jackpot;
  }
  
    
}
