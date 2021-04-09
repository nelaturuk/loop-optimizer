// simple inc range: incRange2(b, 0, a, 0, 10)
contract MyContract{
    mapping (uint => uint) a;
    mapping (uint => uint) b;    
    
    // INDEX: i
    // GUARD: i
    // WRITTEN: a, i
    // READ: a, b, i
    // a' <-- b, a' <-- a, a' <-- i, i' <-- i
    function foo() public{
      for (uint i = 0; i < 10; i++) {
    	a[i] += b[i];
      }
    }

}
