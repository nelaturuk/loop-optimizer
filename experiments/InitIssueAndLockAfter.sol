contract C { 
  uint public unlock_block_number;
  uint[] public amounts;
  address[] public addrs;
  bool public issued;
  address public gt_contract;
    uint total = 0;
    function issue() public {
    uint initial = 0;
    uint initialSum = total; 
    uint loopcondition = addrs.length;
    total = issue_for(initial, initialSum, loopcondition);
  }
  function issue_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + amounts[i];
    }
    return temp_total;
  }  
 
}