// simple shift left: shiftLeft(a, 0, 10)
contract MyContract{
    mapping (uint => uint) a;

    // INDEX: i
    // GUARD: i    
    // WRITTEN: a, i
    // READ: a, i
    // a' <-- a, a' <-- i, i' <-- i
    function foo() public{
      for (uint i = 0; i < 10; i++) {
    	a[i] = a[i+1];
      }
    }

}
