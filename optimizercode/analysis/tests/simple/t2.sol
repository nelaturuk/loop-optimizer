// simple copy range: copyRange2(a, 0, b, 0, 10)
contract MyContract{
    mapping (uint => uint) a;
    mapping (uint => uint) b;

    // INDEX: i
    // GUARD: i    
    // WRITTEN: a, i
    // READ: b, i
    // a' <-- b, a' <-- i, i' <-- i
    function foo() public{
      for (uint i = 0; i < 10; i++) {
    	a[i] = b[i];
      }
    }

}
