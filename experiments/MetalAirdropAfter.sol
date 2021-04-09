contract C { 
    uint256 private constant _decimalFactor = 10**uint256(8);
    mapping (address => bool) public airdrops;
    address[] _recipient;
  function airdropTokens() public {
    bool rvariable = true; 
    uint loopcondition = _recipient.length;
    airdropTokens_for(rvariable, loopcondition);
  }
  function airdropTokens_for(bool rvariable, uint loopcondition) internal {
  for (uint i = 0; i < loopcondition; i++) {
    airdrops[_recipient[i]] = rvariable;
   }
  }
 
}