contract MIUCoin 
{
    bool public isSendGiftOpen  = false;
    bool public auto_lock   = false;
    uint256 public init_lock_period  = 90 days ;
    uint256 public auto_send_amount;  
    mapping (address => uint) public lockedAmount;
    
    address[] public lockedAddress;
    mapping(address => bool) public isExsitLocked;
    uint256 public lockedAddressAmount;
    uint256[] data;
    uint256 S;
    address[] _recivers;
    uint256[] _values;
    uint value;
    
    function sum() public  {
        
        for(uint i = 0;i < data.length;i++) {
            S += data[i];
        }
    }
}