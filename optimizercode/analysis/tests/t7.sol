// simple map: map(a, 0, 10, c)
contract MyContract{
    mapping (uint => uint) a;
    uint c;
    
    // INDEX: i
    // GUARD: i    
    // WRITTEN: a, i
    // READ: i, c
    // a' <-- c, i' <-- i
    function foo() public{
      for (uint i = 0; i < 10; i++) {
    	a[i] = c;
      }
    }

}
