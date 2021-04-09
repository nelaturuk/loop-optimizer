contract VT{
        using SafeMath for uint;
        
        string public symbol;
        string public name;
        uint8 public decimals;
        uint _totalSupply;
        mapping(address => uint) balances;
        mapping(address => mapping(address => uint)) allowed;
        mapping(address => uint) unLockedCoins; // this will keep number of unLockedCoins per address
        struct PC {
        uint256 lockingPeriod;
        uint256 coins;
        bool added;
        }
        PC[] record; // this will keep record of Locking periods and coins per address
        function _updateRecord() public {
    bool rvariable = true; 
    uint initial = 0;
    uint loopcondition = record.length;
    _updateRecord_for(rvariable, initial, loopcondition);
  }
  function _updateRecord_for(bool rvariable, uint initial, uint loopcondition) internal {
  for (uint i = initial; i < loopcondition; i++) {
       if(record[i].lockingPeriod < now && record[i].added == false){
    record[i].added = rvariable;
       }
   }
  }
        
    }