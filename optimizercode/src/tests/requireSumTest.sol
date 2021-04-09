
contract C {
  
  uint256 acc;
  mapping(uint256 => uint256) arr;
  
  function foo() public {
    for (uint i = 0; i < 1; ++i) {
      require(arr[i] > 0);
      acc += arr[i];
    }
  }
}
