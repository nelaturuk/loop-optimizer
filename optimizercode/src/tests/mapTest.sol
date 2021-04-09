
contract C {
  
  uint256 val;
  uint256 start;
  uint256 end;
  mapping(uint256 => uint256) arr;
  
  function foo() public {
    for (uint i = start; i < end; i++) {
      arr[i] = val;
    }
  }
}
