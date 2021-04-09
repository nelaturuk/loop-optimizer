






contract C {
  

  

  address[] addresses;
uint256 amount;
mapping(address => uint256) balanceOf;

  function foo() public {
    
for(uint j = 0; j < addresses.length; j++){
balanceOf[addresses[j]] = ((balanceOf[addresses[j]]) + (amount));
}


  }

  

}

//#LOOPVARS: j


