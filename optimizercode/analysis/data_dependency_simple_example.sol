contract MyContract{
    mapping (uint => uint) a;
    mapping (uint => uint) b;
    mapping (uint => uint) c;
    mapping (uint => uint) d;    

    /* uint e; */
    
    /* uint[] d; */

    // always a' <-- a
    
    // a' <-- b, a' <-- i
    function foo() public{
      for (uint i = 0; i < 10; i++) {
    	a[i] = b[c[i]];
	d[i] = a[i];
      }
    }

    /* // a' <-- b, a' <-- c, a' <-- i */
    /* function foo() public{ */
    /*   for (uint i = 0; i < 10; i++) { */
    /* 	a[i] = b[c[i]]; */
    /*   } */
    /* } */

    /* // a' <-- c, b' <-- a, b' <-- c */
    /* function foo() public{ */
    /*   for (uint i = 0; i < 10; i++) { */
    /* 	a[i] = c[i]; */
    /* 	b[i] = a[i]; */
    /*   } */
    /* } */

    /* // a' <-- b, c' <--d */
    /* function foo() public{ */
    /*   for (uint i = 0; i < 10; i++) { */
    /* 	a[i] = b[i]; */
    /* 	c[i] = d[i] */
    /*   } */
    /* } */

    /* // NONE */
    /* function foo() public{ */
    /*   for (uint i = 0; i < d.length; i++) { */
    /* 	a[i] = i; */
    /*   } */
    /* } */



}
