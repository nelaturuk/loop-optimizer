contract SHUFFLECoin 
{
    using SafeMath for uint;
    
    string public name;
    uint public decimals;
    string public symbol;
    
    uint constant private E18 = 1000000000000000000;
    uint constant private month = 2592000;
    
    uint constant public maxTotalSupply     = 10000000000 * E18;
    
    uint constant public maxSaleSupply      =  2000000000 * E18;
    uint constant public maxCrowdSupply     =  1600000000 * E18;
    uint constant public maxMktSupply       =  2800000000 * E18;
    uint constant public maxTeamSupply      =  1600000000 * E18;
    uint constant public maxReserveSupply   =  1600000000 * E18;
    uint constant public maxAdvisorSupply   =   400000000 * E18;
    
    uint constant public teamVestingSupplyPerTime       = 100000000 * E18;
    uint constant public teamVestingDate                = 2 * month;
    uint constant public teamVestingTime                = 16;
    
    uint public totalTokenSupply;
    
    uint public tokenIssuedSale;
    uint public privateIssuedSale;
    uint public publicIssuedSale;
    uint public tokenIssuedCrowd;
    uint public tokenIssuedMkt;
    uint public tokenIssuedTeam;
    uint public tokenIssuedReserve;
    uint public tokenIssuedAdvisor;
    
    uint public burnTokenSupply;
    
    mapping (address => uint) public balances;
    mapping (address => mapping ( address => uint )) public approvals;
    
    mapping (address => uint) public privateFirstWallet;
    mapping (address => uint) public privateSecondWallet;
    mapping (address => uint) public privateThirdWallet;
    mapping (address => uint) public privateFourthWallet;
    mapping (address => uint) public privateFifthWallet;
    
    mapping (uint => uint) public teamVestingTimeAtSupply;
    
    bool public tokenLock = true;
    bool public saleTime = true;
    uint public endSaleTime = 0;
    
    function endSale() public {
    uint rvariable = teamVestingTime; 
    uint initial = 1;
    uint loopcondition = teamVestingTime;
    endSale_for(rvariable, initial, loopcondition);
  }
  function endSale_for(bool rvariable, uint initial, uint loopcondition) internal {
  for (uint i = initial; i < loopcondition; i++) {
    teamVestingTimeAtSupply[i] += rvariable;
   }
  }
}
