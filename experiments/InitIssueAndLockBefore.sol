contract InitIssueAndLock{
  uint public unlock_block_number;
  uint[] public amounts;
  address[] public addrs;
  bool public issued;
  address public gt_contract;
    uint total = 0;

  function issue() public{
    
    for(uint i = 0; i < addrs.length; i++){
      total = total + amounts[i];
    }
  }
}