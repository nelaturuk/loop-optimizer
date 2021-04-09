contract localElection{
    address payable public owner;
    string public encryptionPublicKey; //Just keep record on the vote encryption key
    bool public isRunningElection = false;
	mapping(address => bool) public approvedVoteBox;
	mapping(uint256 => bool) public voterList;
	mapping(uint256 => uint256) public usedPhoneNumber;
	mapping(uint256 => mapping(string => bool)) public councilVoterList;
	mapping(string => uint) public councilVoterNumber;
	mapping(uint256 => string) private voteListByVoter; 
	mapping(string => string[]) private votes; //Votes grouped by council
	mapping(address => string[]) private voteByVotebox; //Votes grouped by votebox
	mapping(string => bool) private voteDictionary; //Makre sure votes are unique
	mapping(string => address) public invalidVotes;
	
	address public dbAddress;
    uint councilNumber;
    address box;
    uint voterID;
	
	function deregister() 
	{
		for(uint i=0;i<councilNumber;i++){
			councilVoterList[voterID][encryptionPublicKey] = false;
		}
	}
}