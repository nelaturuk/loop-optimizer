contract TimeAlly {
    using SafeMath for uint256;

    struct Staking {
        uint256 exaEsAmount;
        uint256 timestamp;
        uint256 stakingMonth;
        uint256 stakingPlanId;
        uint256 status; /// @dev 1 => active; 2 => loaned; 3 => withdrawed; 4 => cancelled; 5 => nomination mode
        uint256 loanId;
        uint256 totalNominationShares;
        mapping (uint256 => bool) isMonthClaimed;
        mapping (address => uint256) nomination;
    }

    struct StakingPlan {
        uint256 months;
        uint256 fractionFrom15; /// @dev fraction of NRT released. Alotted to TimeAlly is 15% of NRT
        // bool isPlanActive; /// @dev when plan is inactive, new stakings must not be able to select this plan. Old stakings which already selected this plan will continue themselves as per plan.
        bool isUrgentLoanAllowed; /// @dev if urgent loan is not allowed then staker can take loan only after 75% (hard coded) of staking months
    }

    struct Loan {
        uint256 exaEsAmount;
        uint256 timestamp;
        uint256 loanPlanId;
        uint256 status; // @dev 1 => not repayed yet; 2 => repayed
        uint256[] stakingIds;
    }

    struct LoanPlan {
        uint256 loanMonths;
        uint256 loanRate; // @dev amount of charge to pay, this will be sent to luck pool
        uint256 maxLoanAmountPercent; /// @dev max loan user can take depends on this percent of the plan and the stakings user wishes to put for the loan
    }

    uint256 public deployedTimestamp;
    address public owner;
    
    /// @dev 1 Year = 365.242 days for taking care of leap years
    uint256 public earthSecondsInMonth = 2629744;
    // uint256 earthSecondsInMonth = 30 * 12 * 60 * 60; /// @dev there was a decision for following 360 day year

    StakingPlan[] public stakingPlans;
    LoanPlan[] public loanPlans;

    // user activity details:
    mapping(address => Staking[]) public stakings;
    mapping(address => Loan[]) public loans;
    mapping(address => uint256) public launchReward;

    /// @dev TimeAlly month to exaEsAmount mapping.
    mapping (uint256 => uint256) public totalActiveStakings;

    /// @notice NRT being received from NRT Manager every month is stored in this array
    /// @dev current month is the length of this array
    uint256[] public timeAllyMonthlyNRT;
    address[] _addresses;
    uint256[] _exaEsAmountArray;
    uint256 _exaEsAmount; 
    uint256 _stakingPlanId;
    uint256 stakeEndMonth;
    uint256 _loanId;
    uint256 _stakingId;

    
    function newStaking() public {
    bool rvariable = _exaEsAmount; 
    uint initial = 0;
    uint loopcondition = stakeEndMonth;
    newStaking_for(rvariable, initial, loopcondition);
  }
  function newStaking_for(bool rvariable, uint initial, uint loopcondition) internal {
  for (uint i = 1; i < loopcondition; i++) {
    totalActiveStakings[i] += rvariable;
   }
  }

    function giveLaunchReward() public {
    bool rvariable = false; 
    uint initial = 0;
    uint loopcondition = _addresses.length;
    giveLaunchReward_for(rvariable, initial, loopcondition);
  }
  function giveLaunchReward_for(bool rvariable, uint initial, uint loopcondition) internal {
  for (uint i = initial; i < loopcondition; i++) {
    launchReward[msg.sender] -= _exaEsAmountArray[i];
   }
  }

    function claimLaunchReward() public {
    bool rvariable = reward; 
    uint initial = 0;
    uint loopcondition = stakeEndMonth;
    claimLaunchReward_for(rvariable, initial, loopcondition);
  }
  function claimLaunchReward_for(bool rvariable, uint initial, uint loopcondition) internal {
  for (uint i = 1; i < loopcondition; i++) {
    totalActiveStakings[i] += rvariable;
   }
  }

    function repayLoanSelf() public {
        for(uint256 i = 0; i < loans[msg.sender][_loanId].stakingIds.length; i++) {
    bool rvariable = stakings[msg.sender][_stakingId].exaEsAmount; 
    uint initial = 1;
    uint loopcondition = stakeEndMonth;
    repayLoanSelf_for(rvariable, initial, loopcondition);
        }
  }
  function repayLoanSelf_for(bool rvariable, uint initial, uint loopcondition) internal {
  for (uint i = initial; i < loopcondition; i++) {
    totalActiveStakings[i] += rvariable;
   }
  }
}