
contract C {
  
  uint256 val;
  uint256 start;
  uint256 end;
  mapping(uint256 => uint256) idx_arr;
  mapping(uint256 => uint256) tgt_arr;  
  
  function foo() public {
    for (uint i = start; i < end; i++) {
      tgt_arr[idx_arr[i]] = val;
    }
  }
}
