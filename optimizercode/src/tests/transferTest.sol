
contract C {
  
  uint256 i;
  uint256 strt;
  uint256 end;
  mapping(uint256 => address) to;
  mapping(uint256 => uint256) amnt;

  mapping (address => uint256) _balances;
  
  function foo() public {
    for (uint i = strt; i < end; ++i) {
      transfer(to[i], amnt[i]);
    }
  }

  function transfer(address recipient, uint256 amount) public returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0));
    require(recipient != address(0));
    
    _balances[sender] = _balances[sender] - amount;
    _balances[recipient] = _balances[recipient] + amount;
  }

}
