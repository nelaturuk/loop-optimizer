contract C { 
    uint256 public sellPrice;
    uint256 public buyPrice;
    mapping (address => bool) public frozenAccount;
     uint256[] _amount;
     uint256 sum;
    function batchTransfer() public {
    uint initial = 0;
    uint initialSum = sum; 
    uint loopcondition = _amount.length;
    sum = batchTransfer_for(initial, initialSum, loopcondition);
  }
  function batchTransfer_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + _amount[i];
    }
    return temp_total;
  }  
 
}