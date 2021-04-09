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
    
    function authorizeUsers() {
        for( uint256 i = 0; i < _users.length; i += 1 ) {
            tknUnlocked = tknUnlocked + tknUserPending[_users[i]];
        }
    }

    function authorizeUsers2() onlyOwner public {
        for( uint256 i = 0; i < _users.length; i += 1 ) {
            tknUserPending[_users[i]] = 0;
        }
    }
}