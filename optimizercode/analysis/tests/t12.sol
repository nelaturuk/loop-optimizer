// multiple statement transativity test (easy)
contract MyContract{
    mapping (uint => uint) a;
    mapping (uint => uint) b;
    mapping (uint => uint) c;    
    
    // INDEX: i
    // GUARD: i
    // WRITTEN: a, c, i
    // READ: b, a, i
    // a' <-- b, a' <-- i, c' <-- a, c' <-- b, c' <-- i, i' <-- i
    function foo() public{
      for (uint i = 0; i < 10; i++) {
    	a[i] = b[i];
	c[i] = a[i];
      }
    }

}
