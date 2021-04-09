contract League {
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

    function calcLocked() public{
        
        for(uint i=0; i<lockedRound.length; i++){
            randTotal = randTotal + lockedRound[i];
        }
    }

    function startArgs() public {
        for(uint i=0; i<locks.length; i++) {
            lockedRound[i] = locks[i];
        }
    }

}