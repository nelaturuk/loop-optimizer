// multiple statement NO transativity test
contract MyContract{
    mapping (uint => uint) a;
    mapping (uint => uint) b;
    mapping (uint => uint) c;    
    
    // INDEX: i
    // GUARD: i
    // WRITTEN: a, b, i
    // READ: b, c, i
    // a' <-- b, a' <-- i, b' <-- c, b' <-- i, i' <-- i
    function foo() public{
      for (uint i = 0; i < 10; i++) {
    	a[i] = b[i];
	b[i] = c[i];
      }
    }

}
