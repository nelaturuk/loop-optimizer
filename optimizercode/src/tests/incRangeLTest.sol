
contract C {
  
  uint256 start;
  uint256 end;
  mapping(uint256 => uint256) src_arr;
  mapping(uint256 => uint256) tgt_arr;  
  
  function foo() public {
    for (uint i = start; i < end; i++) {
      tgt_arr[i] += src_arr[i]*5;
    }
  }
}
