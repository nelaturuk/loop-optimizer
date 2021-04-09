contract C { 
    uint public _dailyInvest = 0;
    uint public _staticPool = 0;
    uint public _outInvest = 0;
    uint public _safePool = 0;
    uint public _gloryPool = 0;
    address[] public allAddress = new address[](0);
    uint[] public lockedRound = new uint[](0);
    uint investCount = 0;
    address[] public dailyPlayers = new address[](0);
    uint _rand = 88;
    uint _safeIndex = 0;
    uint _endTime = 0;
    uint _startTime = 0;
    bool public _active = true;
    uint randTotal = 0;
    uint[] locks;
    function startArgs() public {
    uint initial = 0;
    uint mapstart = 0;
    uint mapend = 0;
    uint loopcondition = locks.length;
    startArgs_for(initial, loopcondition, mapstart, mapend);
  }
  function startArgs_for(uint initial, uint loopcondition, uint _mapstart, uint _mapend) internal {
  for (uint i = initial; i < loopcondition; ++i) {
          lockedRound[i + _mapstart] = locks[i + _mapend];
    }
  }
    function calcLocked() public {
    uint initial = 0;
    uint initialSum = randTotal; 
    uint loopcondition = lockedRound.length;
    randTotal = calcLocked_for(initial, initialSum, loopcondition);
  }
  function calcLocked_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + lockedRound[i];
    }
    return temp_total;
  }  
 
}