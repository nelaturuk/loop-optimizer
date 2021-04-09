contract MACH  {
    
    struct LockInfo {
        uint256 _releaseTime;
        uint256 _amount;
    }
    
    address public implementation;

    mapping (address => LockInfo[]) public timelockList;
	mapping (address => bool) public frozenAccount;
    uint256 totalBalance;
    
     function balanceOf() public {
    uint initial = 0;
    uint initialSum = totalBalance; 
    uint loopcondition = timelockList[msg.sender].length;
    totalBalance = balanceOf_for(initial, initialSum, loopcondition);
  }
  function balanceOf_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
     if( loopcondition >0 ){
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + timelockList[msg.sender][i]._amount;
    }
     }
    return temp_total;
  } 
}