


contract C {
  

  uint256 i;
uint256 len;
address[] _targets;

  function foo() public {
    
for(uint256 i = 0; i < len; i = (i) + (1)){
require(_targets[i] != address(0));
}


  }
}

//#LOOPVARS: i
