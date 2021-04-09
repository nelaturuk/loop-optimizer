pragma solidity ^0.5.10;

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
    acc = 0;
    /* for (uint i = 0; i < lockNum[_address]; ++i) { */
    for (uint i = strt; i < end; ++i) {
      acc += arr[i];
      /* arr[i] = lockTimes[_address][i]; */
      /* lockTime[_address][i] = arr[i]; */
      /* lockTime[_address][i] = lockTime[_address][i]; */
    }
  }
}
