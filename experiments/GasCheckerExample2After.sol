contract GasCheckerExample2After { 
    uint public numoptions00; //in storage3    
    uint[] public strikes0;
    uint[] public options0;
    bool check = true;

    /**
     * @notice modifies GasCheckerExample2After.options0
     * @notice modifies GasCheckerExample2After.numoptions00
     * @notice postcondition strikes0.length ==  __verifier_old_uint(strikes0.length)
     * @notice postcondition forall (uint a) exists (uint j) (j >=0 && j < strikes0.length && numoptions00 > 20 && (options0[a] == strikes0[j])) || (options0[a] == __verifier_old_uint(options0[a]))
     */
    function setVar0() public {
    uint initial = 0;
    uint mapstart = 0;
    uint mapend = 0;
    uint loopcondition = strikes0.length;
    setVar_for(initial, loopcondition, mapstart, mapend);
  }

  /**
     * @notice modifies options0
     * @notice modifies numoptions00
     * @notice postcondition strikes0.length ==  __verifier_old_uint(strikes0.length)
     * @notice postcondition options0.length ==  __verifier_old_uint(options0.length)
     * @notice postcondition forall (uint a) exists (uint j) (j >=0 && j < loopcondition && numoptions00 > 20 && (options0[a] == strikes0[j])) || (options0[a] == __verifier_old_uint(options0[a]))
     */
  function setVar_for(uint initial, uint loopcondition, uint _mapstart, uint _mapend) internal {
    uint i = 0;
    require(loopcondition>0);
    /**
         * @notice invariant options.length ==  __verifier_old_uint(options.length)
         * @notice invariant forall (uint a) exists (uint j) (j >=0 && j < strikes0.length && numoptions00 > 20 && (options0[a] == strikes0[j])) || (options0[a] == __verifier_old_uint(options0[a]))
         */
    for (i = initial; i < loopcondition; ++i) {
        require(numoptions00 > 0);
        if (numoptions00 > 20){
            options0[numoptions00++ +_mapstart] = strikes0[i + _mapend];
        }
    }
  }  
}