
contract C {
  
  uint256 strt;
  uint256 end;
  address[] addrs;
  mapping(uint256 => uint256) src_arr;
  mapping(address => uint256) tgt_arr;  
  
  function foo() public {
    for (uint i = strt; i < end; i++) {
      tgt_arr[addrs[i]] += src_arr[i];
    }
  }
}
