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

    

    /// @notice takes ES from user and locks it for a time according to plan selected by user
    /// @param _exaEsAmount - amount of ES tokens (in 18 decimals thats why 'exa') that user wishes to stake
    /// @param _stakingPlanId - plan for staking
    function newStaking() public {

        for(
          uint256 month = 1;
          month <= stakeEndMonth;
          month++
        ) {
            totalActiveStakings[month] = totalActiveStakings[month] + _exaEsAmount;
        }
    }

    
    /// @notice this function is used to send rewards to multiple users
    /// @param _addresses - array of address to send rewards
    /// @param _exaEsAmountArray - array of ExaES amounts sent to each address of _addresses with same index
    function giveLaunchReward() public onlyOwner {
        for(uint256 i = 0; i < _addresses.length; i++) {
            launchReward[msg.sender] = launchReward[msg.sender] - _exaEsAmountArray[i];
            // launchReward[_addresses[i]] = launchReward[_addresses[i]].add(_exaEsAmountArray[i]);
        }
    }

    /// @notice this function is used by rewardees to claim their accrued rewards. This is also used by stakers to restake their 50% benefit received as rewards
    /// @param _stakingPlanId - rewardee can choose plan while claiming rewards as stakings
    function claimLaunchReward() public {
        for(
          uint256 month = 1;
          month <= stakeEndMonth;
          month++
        ) {
            totalActiveStakings[month] = totalActiveStakings[month] + reward; /// @dev reward means locked ES which only staking option
        }
    }

    /// @notice repay loan functionality
    /// @dev need to give allowance before this
    function repayLoanSelf() public {
        for(uint256 i = 0; i < loans[msg.sender][_loanId].stakingIds.length; i++) {
            for(uint256 j = 1; j <= stakeEndMonth; j++) {
                totalActiveStakings[j] = totalActiveStakings[j] + stakings[msg.sender][_stakingId].exaEsAmount;
            }
        }
    }
}