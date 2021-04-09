contract C { 
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
    function sum() public {
    uint initial = 0;
    uint initialSum = S; 
    uint loopcondition = data.length;
    S = sum_for(initial, initialSum, loopcondition);
  }
  function sum_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + data[i];
    }
    return temp_total;
  }  
 
}