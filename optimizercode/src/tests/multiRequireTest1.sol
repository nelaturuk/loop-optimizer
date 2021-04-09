






contract C {
  

  

  address[] addresses;
mapping(address => bool) frozenAccount;
mapping(address => uint256) unlockUnixTime;
uint256 now;
uint256 amount;
mapping(address => uint256) balanceOf;

  function foo() public {
    
for(uint j = 0; j < addresses.length; j++){
require(addresses[j] != 0);
require(frozenAccount[addresses[j]] == false);
require(now > unlockUnixTime[addresses[j]]);
}


  }

  

}

//#LOOPVARS: j


