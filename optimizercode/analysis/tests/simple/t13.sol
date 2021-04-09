// multiple statement transativity test (easy)
contract MyContract{
    mapping (uint => uint) a;
    mapping (uint => uint) b;
    uint c;
    
    // INDEX: i
    // GUARD: i
    // WRITTEN: a, i
    // READ: b, c, i
    // a' <-- b, a' <-- i, a' <-- c, i' <-- i
    function foo() public{
      for (uint i = c; i < 10; i++) {
    	a[i] = b[i];
      }
    }

}
