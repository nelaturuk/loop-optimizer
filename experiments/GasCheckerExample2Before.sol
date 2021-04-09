contract GasCheckerExample2Before {
    uint public numOptions; //in storage3    
    uint[] public strikes;
    uint[] public options;


    /**
     * @notice modifies GasCheckerExample2Before.options
     * @notice modifies GasCheckerExample2Before.numOptions
     * @notice postcondition strikes.length ==  __verifier_old_uint(strikes.length)
     * @notice postcondition options.length ==  __verifier_old_uint(options.length)
     * @notice postcondition forall (uint a) exists (uint j) (j <  strikes.length && options[a] == strikes[j]) || (options[a] == __verifier_old_uint(options[a]))
     * @notice postcondition forall (uint a) exists (uint j) (j >=0 && j < strikes.length && numOptions > 20 && (options[a] == strikes[j])) || (options[a] == __verifier_old_uint(options[a]))
     */
    function setVar() public
    {  
        uint i = 0; 
        require(strikes.length > 0);
        /**
         * @notice invariant options.length ==  __verifier_old_uint(options.length)
         * @notice invariant forall (uint a) exists (uint j) (j >=0 && j < strikes.length && numOptions > 20 && (options[a] == strikes[j])) || (options[a] == __verifier_old_uint(options[a]))
         */
        for(i = 0; i < strikes.length && numOptions < options.length - 1; i++)
        {  
            require(numOptions > 0);
            if (numOptions > 20) {
                options[numOptions++] = strikes[i];
            }
        } 
    } 
}