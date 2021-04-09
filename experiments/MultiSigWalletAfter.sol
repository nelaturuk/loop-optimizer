contract MultiSigWallet {

    uint constant public MAX_OWNER_COUNT = 50;

    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    address owner;
    address newOwner;
    uint public required;
    uint public transactionCount;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    uint transactionId;
    uint count;

    function removeOwner() public {
    uint initial = 0;
    uint mapstart = 0;
    uint mapend = 0;
    uint loopcondition = owners.length;
    removeOwner_for(initial, loopcondition, mapstart, mapend);
  }
  function removeOwner_for(uint initial, uint loopcondition, uint _mapstart, uint _mapend) internal {
  for (uint i = initial; i < loopcondition; ++i) {
          _nftIds[i + _mapstart] = tokenIds[loopcondition + _mapend];
    }
  }

  function replaceOwner() public {
    address rvariable = newOwner; 
    uint initial = 0;
    uint loopcondition = owners.length;
    replaceOwner_for(rvariable, initial, loopcondition);
  }
  function replaceOwner_for(bool rvariable, uint initial, uint loopcondition) internal {
  for (uint i = initial; i < loopcondition; i++) {
      if (owners[i] == owner) {
    owners[i] = rvariable;
      }
   }
  }

  function isConfirmed() public {
    uint initial = 0;
    uint initialSum = count; 
    uint loopcondition = owners.length;
    count = isConfirmed_for(initial, initialSum, loopcondition);
  }
  function isConfirmed_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + 1;
    }
    return temp_total;
  }  
}