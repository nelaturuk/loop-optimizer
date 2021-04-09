contract EticaReleaseBefore  {

struct Period{
    uint id;
    uint interval;
    uint curation_sum; // used for proposals weight system
    uint editor_sum; // used for proposals weight system
    uint reward_for_curation; // total ETI issued to be used as Period reward for Curation
    uint reward_for_editor; // total ETI issued to be used as Period reward for Editor
    uint forprops; // number of accepted proposals in this period
    uint againstprops; // number of rejected proposals in this period
}

  struct Stake{
      uint amount;
      uint endTime; // Time when the stake will be claimable
  }

 struct Proposal{
      uint id;
      bytes32 proposed_release_hash; // Hash of "raw_release_hash + name of Disease"
      bytes32 disease_id;
      uint period_id;
      uint chunk_id;
      address proposer; // address of the proposer
      string title; // Title of the Proposal
      string description; // Description of the Proposal
      string freefield;
      string raw_release_hash;
  }

  struct ProposalData{

      uint starttime; // epoch time of the proposal
      uint endtime;  // voting limite
      uint finalized_time; // when first clmpropbyhash() was called
      ProposalStatus status; // Only updates once, when the voting process is over
      ProposalStatus prestatus; // Updates During voting process
      bool istie;  // will be initialized with value 0. if prop is tie it won't slash nor reward participants
      uint nbvoters;
      uint slashingratio; // solidity does not support float type. So will emulate float type by using uint
      uint forvotes;
      uint againstvotes;
      uint lastcuration_weight; // period curation weight of proposal
      uint lasteditor_weight; // period editor weight of proposal
  }

    struct Chunk{
    uint id;
    bytes32 diseaseid; // hash of the disease
    uint idx;
    string title;
    string desc;
  }

  struct Vote{
    bytes32 proposal_hash; // proposed_release_hash of proposal
    bool approve;
    bool is_editor;
    uint amount;
    address voter; // address of the voter
    uint timestamp; // epoch time of the vote
    bool is_claimed; // keeps track of whether or not vote has been claimed to avoid double claim on same vote
  }

    struct Commit{
    uint amount;
    uint timestamp; // epoch time of the vote
  }
  struct Disease{
      bytes32 disease_hash;
      string name;
  }

     // -----------  DISEASES STRUCTS ----------------  //

mapping(uint => Period) public periods;
uint public periodsCounter;
mapping(uint => uint) public PeriodsIssued; // keeps track of which periods have already issued ETI
uint public PeriodsIssuedCounter;
mapping(uint => uint) public IntervalsPeriods; // keeps track of which intervals have already a period
uint public IntervalsPeriodsCounter;

mapping(uint => Disease) public diseases; // keeps track of which intervals have already a period
uint public diseasesCounter;
mapping(bytes32 => uint) public diseasesbyIds; // get disease.index by giving its disease_hash: example: [leiojej757575ero] => [0]  where leiojej757575ero is disease_hash of a Disease
mapping(string => bytes32) private diseasesbyNames; // get disease.disease_hash by giving its name: example: ["name of a disease"] => [leiojej757575ero]  where leiojej757575ero is disease_hash of a Disease. Set visibility to private because mapping with strings as keys have issues when public visibility

mapping(bytes32 => mapping(uint => bytes32)) public diseaseproposals; // mapping of mapping of all proposals for a disease
mapping(bytes32 => uint) public diseaseProposalsCounter; // keeps track of how many proposals for each disease

// -----------  PROPOSALS MAPPINGS ------------  //
mapping(bytes32 => Proposal) public proposals;
mapping(uint => bytes32) public proposalsbyIndex; // get proposal.proposed_release_hash by giving its id (index): example: [2] => [huhihgfytoouhi]  where huhihgfytoouhi is proposed_release_hash of a Proposal
uint public proposalsCounter;

mapping(bytes32 => ProposalData) public propsdatas;
// -----------  PROPOSALS MAPPINGS ------------  //

// -----------  CHUNKS MAPPINGS ----------------  //
mapping(uint => Chunk) public chunks;
uint public chunksCounter;
mapping(bytes32 => mapping(uint => uint)) public diseasechunks; // chunks of a disease
mapping(uint => mapping(uint => bytes32)) public chunkproposals; // proposals of a chunk
mapping(bytes32 => uint) public diseaseChunksCounter; // keeps track of how many chunks for each disease
mapping(uint => uint) public chunkProposalsCounter; // keeps track of how many proposals for each chunk
// -----------  CHUNKS MAPPINGS ----------------  //

// -----------  VOTES MAPPINGS ----------------  //
mapping(bytes32 => mapping(address => Vote)) public votes;
mapping(address => mapping(bytes32 => Commit)) public commits;
// -----------  VOTES MAPPINGS ----------------  //

mapping(address => uint) public bosoms;
mapping(address => mapping(uint => Stake)) public stakes;
mapping(address => uint) public stakesCounters; // keeps track of how many stakes for each user
mapping(address => uint) public stakesAmount; // keeps track of total amount of stakes for each user

// Blocked ETI amount, user has votes with this amount in process and can't retrieve this amount before the system knows if the user has to be slahed
mapping(address => uint) public blockedeticas;
uint256 _totalfor;
uint256 _totalagainst;
uint256 _currentidx;

/**
     * @notice modifies EticaReleaseBefore._totalfor
     * @notice postcondition _totalfor >= __verifier_old_uint(_totalfor)
     * @notice postcondition _totalfor == __verifier_old_uint(_totalfor) + __verifier_sum_uint(periods.forprops)
     */
function readjustThreshold1()  {
uint256 i = 0;
        require(periodsCounter-1 > 0);
        /**
         * @notice invariant _totalfor >= __verifier_old_uint(_totalfor)
         * @notice invariant _totalfor == __verifier_old_uint(_totalfor) + sum(periods[0].forprops ... periods[i].forprops)
         */
for(i = periodsCounter.sub(PERIODS_PER_THRESHOLD); i <= periodsCounter -1;  i++){
   _totalfor = _totalfor + periods[i].forprops;
   
}
}

/**
     * @notice modifies EticaReleaseBefore._totalagainst
     * @notice postcondition _totalagainst >= __verifier_old_uint(_totalagainst)
     * @notice postcondition _totalagainst == __verifier_old_uint(_totalagainst) + __verifier_sum_uint(periods.againstprops)
     */
function readjustThreshold2()  {
uint256 i = 0;
        require(periodsCounter.sub(1) > 0);
        /**
         * @notice invariant _totalagainst >= __verifier_old_uint(_totalagainst)
         * @notice invariant _totalagainst == __verifier_old_uint(_totalagainst) + sum(periods[0].againstprops ... periods[i].againstprops)
         */
for(i = periodsCounter.sub(PERIODS_PER_THRESHOLD); i <= periodsCounter-1;  i++){
   _totalagainst = _totalagainst + periods[i].againstprops; 
}
}
}
