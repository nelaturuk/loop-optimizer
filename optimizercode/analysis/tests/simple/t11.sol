// multiple statement transativity test
// NOTE: This one is quite tricky, it requires reasoning that b[i+1]
//       is equal to b[i] of the next loop...
contract MyContract{
    mapping (uint => uint) a;
    mapping (uint => uint) b;
    mapping (uint => uint) c;    
    
    // INDEX: i
    // GUARD: i
    // WRITTEN: a, b, i
    // READ: b, c, i
    // a' <-- b, a' <-- i, a' <-- c, b' <-- c, b' <-- i, i' <-- i
    function foo() public{
      for (uint i = 0; i < 10; i++) {
    	a[i] = b[i];
	b[i+1] = c[i];
      }
    }

}
