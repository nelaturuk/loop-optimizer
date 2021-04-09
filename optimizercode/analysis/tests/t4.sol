contract MyContract{
    mapping (uint => uint) a;
    mapping (uint => uint) b;
    mapping (uint => uint) c;

    // INDEX: i, c
    // GUARD: i    
    // WRITTEN: a, i
    // READ: b, c, i
    // a' <-- b, a' <-- c, a' <-- i, i' <-- i
    function foo() public{
      for (uint i = 0; i < 10; i++) {
    	a[i] = b[c[i]];
      }
    }

}
