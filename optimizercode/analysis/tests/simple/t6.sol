// simple update range: updateRange(b, a, c)
contract MyContract{
    mapping (uint => uint) a;
    mapping (uint => uint) b;    
    uint c;
    
    // INDEX: b, i
    // GUARD: i    
    // WRITTEN: a, i
    // READ: b, i, c
    // i' <-- i, a' <-- c
    function foo() public{
      for (uint i = 0; i < 10; i++) {
    	a[b[i]] = c;
      }
    }

}
