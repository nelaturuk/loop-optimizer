contract MACH  {
    
    struct LockInfo {
        uint256 _releaseTime;
        uint256 _amount;
    }
    
    address public implementation;

    mapping (address => LockInfo[]) public timelockList;
	mapping (address => bool) public frozenAccount;
    uint256 totalBalance;
    
    function balanceOf()  {
        
        if( timelockList[msg.sender].length >0 ){
            for(uint i=0; i<timelockList[msg.sender].length;i++){
                totalBalance = totalBalance + timelockList[msg.sender][i]._amount;
            }
        }
    }
}