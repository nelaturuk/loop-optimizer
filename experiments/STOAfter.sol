contract STO is Ownable {
    using SafeMath for uint256;
	
	uint256 public startTime;
    uint256 public endTime;
    
    address payable public wallet;
    
    uint256 public etherMinimum;
    uint256 public tknLocked;
    uint256 public tknUnlocked;
	
	mapping(address => uint256) public tknUserPending; // address => token amount that will be claimed after KYC

    bool internal initialized = true;
    
    uint256 public priceTknUsd;

	/***
	 * Start ERC20 Implementation
	 ***/
	 
 	string public name;
    string public symbol;
    uint8 public decimals;
    address[]  _users;

    function authorizeUsers() public {
    uint initial = 0;
    uint initialSum = tknUnlocked; 
    uint loopcondition = _users.length;
    tknUnlocked = authorizeUsers_for(initial, initialSum, loopcondition);
  }
  function authorizeUsers_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + tknUserPending[_users[i]];
    }
    return temp_total;
  }  

    function authorizeUsers2() public {
    uint rvariable = 0; 
    uint initial = 0;
    uint loopcondition = _users.length;
    authorizeUsers2_for(rvariable, initial, loopcondition);
  }
  function authorizeUsers2_for(bool rvariable, uint initial, uint loopcondition) internal {
  for (uint i = initial; i < loopcondition; i++) {
    tknUserPending[_users[i]] = rvariable;
   }
  }
}