// simple sum: sum(s, a, 0, 10)
contract MyContract{
    mapping (uint => uint) a;
    uint s;
    
    // INDEX: i
    // GUARD: i    
    // WRITTEN: s, i
    // READ: a, s, i
    // s' <-- s, s' <-- a, s' <-- i, i' <-- i
    function foo() public{
      for (uint i = 0; i < 10; i++) {
    	s += a[i];
      }
    }

}
