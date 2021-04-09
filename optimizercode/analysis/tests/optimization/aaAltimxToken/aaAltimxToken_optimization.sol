pragma solidity ^0.5.10;

contract MyContract {

  uint256 public constant Factor = 1000;
  uint256 public tokensInVaults;
  uint256 totalSupply_;
  
  function foo(uint256[] memory _amountOfLands) public returns (uint256) {
    uint256 totalAmount = 0;
    for (uint256 i = 0; i < _amountOfLands.length; i++) {
      uint256 amount = _amountOfLands[i] * Factor;
      totalAmount = totalAmount + amount;
    }
    return totalAmount;
  }
    
}
