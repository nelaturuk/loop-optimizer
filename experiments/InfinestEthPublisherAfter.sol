contract C { 
    address public _owner;
    mapping(address => bool) public _approved;
  uint256[] _amountList;
    uint256 balance = 0;
     uint256 sumOfBalances = 0;
    function drop() public {
    uint initial = 0;
    uint initialSum = sumOfBalances; 
    uint loopcondition = _amountList.length;
    sumOfBalances = drop_for(initial, initialSum, loopcondition);
  }
  function drop_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + _amountList[i];
    }
    return temp_total;
  }  
 
}