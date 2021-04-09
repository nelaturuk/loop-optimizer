
contract C {
  
  address _address; 
  uint256 i;
  uint256 strt;
  uint256 end;
  uint256 acc;
  mapping(uint256 => uint256) arr;
  mapping(address => uint256) lockNum; 
  mapping(address => uint256[]) lockTime; 
  
  function foo() public {
    for (uint i = strt; i < end; ++i) {
      require(arr[i]>arr[i+1]);
    }
  }
}
