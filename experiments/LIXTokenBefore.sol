contract LIXTokenBefore
{
    mapping (uint => uint) public operVestingTimer;
    mapping (uint => uint) public operVestingBalances;
    
    mapping (uint => uint) public mktVestingTimer;
    mapping (uint => uint) public mktVestingBalances;
    
    mapping (uint => uint) public bDevVestingTimer;
    mapping (uint => uint) public bDevVestingBalances;
    
    uint public rsvVestingTime;
    
    mapping (uint => uint) public eventVestingTimer;
    mapping (uint => uint) public eventVestingBalances;
    
    bool public tokenLock = true;
    bool public saleTime = true;
    uint public endSaleTime = 0;
    uint public lockTime;
    uint public operVestingTime; 
    
    // -----
    
    // ETC / Burn Function -----
    /**
     * @notice modifies LIXTokenBefore.operVestingTimer
     * @notice postcondition forall (uint i) !(1 <= i && i < operVestingTime) || (operVestingTimer[i] == lockTime)
     * @notice postcondition operVestingTime == __verifier_old_uint(operVestingTime)
     * @notice postcondition exists (uint j) (j < operVestingTime) || (operVestingTimer[j] == __verifier_old_uint(operVestingTimer[j]))
     */
    function endSale() public
    {
        uint i = 1;
        require(operVestingTime > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 1 ) || (operVestingTimer[j] == lockTime)
         * @notice invariant exists (uint j) (j < operVestingTime) || (operVestingTimer[j] == __verifier_old_uint(operVestingTimer[j]))
         */
        for(i = 1; i < operVestingTime; i++)
        {
            operVestingTimer[i] = lockTime;
        }
    }
    
    // -----
}