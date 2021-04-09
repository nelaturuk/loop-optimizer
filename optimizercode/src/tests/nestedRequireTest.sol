
contract C {

  uint256 i;
  uint256 strt;
  uint256 end;
  address[] addrs;
  mapping(address => uint256) intArr; 
  
  function foo() public {
    for (uint i = strt; i < end; ++i) {
      require(intArr[addrs[i]] > 0);
    }
  }
}
