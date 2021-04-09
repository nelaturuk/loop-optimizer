

contract C {
  
  uint256 strt;
  uint256 end;
  mapping(uint256 => uint256) src_arr;
  mapping(uint256 => uint256) tgt_arr;  
  
  function foo() public {
    for (uint i = strt; i < end; i++) {
      tgt_arr[i] = src_arr[i]*5;
    }
  }
}
