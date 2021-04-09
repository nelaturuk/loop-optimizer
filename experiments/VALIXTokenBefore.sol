contract VALLIXTokenBefore
{   
    uint constant public teamVestingSupplyPerTime       = 100000000;
    uint constant public teamVestingTime                = 16;
    
    uint public totalTokenSupply;
    
    mapping (uint => uint) public teamVestingTimeAtSupply;
    
    function endSale() public
    {
        for(uint i = 1; i <= teamVestingTime; i++)
        {
            teamVestingTimeAtSupply[i] = teamVestingTimeAtSupply[i] + teamVestingSupplyPerTime;
        }
       
    } 
}