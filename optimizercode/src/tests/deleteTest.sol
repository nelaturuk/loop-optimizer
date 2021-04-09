






contract C {
  

  

  mapping(address => bool) KYC;
uint256 i;
address[] _off;

  function foo() public {
    
for(uint i = 0; i < _off.length; i++){
delete KYC[_off[i]];
// KYC[_off[i]] = 0;
// KYC[_off[i]] = false;
}


  }

  

}

//#LOOPVARS: i


