
contract C {
  
  uint256 strt;
  uint256 end;
  uint256 acc;
  address[] addrs;
  mapping(address => uint256) src_arr;
  
  function foo() public {
    for (uint i = strt; i < end; i++) {
      acc += src_arr[addrs[i]];
    }
  }
}
