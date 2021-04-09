contract WeightMultiSig{

  struct invoke_status{
    uint propose_height;
    bytes32 invoke_hash;
    string func_name;
    uint64 invoke_id;
    bool called;
    address[] invoke_signers;
    bool processing;
    bool exists;
  }

  uint public signer_number;
  address[] public signers;
  address[] public accounts;
  mapping (address => uint) public weights;
  uint public total_weight;
  address public owner;
  mapping (bytes32 => invoke_status) public invokes;
  mapping (bytes32 => uint64) public used_invoke_ids;
  mapping(address => uint) public signer_join_height;
  bool is_array_exist = false;
  uint valid_invoke_weight;

  function array_exist() public {
    bool rvariable = true; 
    uint initial = 0;
    uint loopcondition = signers.length;
    array_exist_for(rvariable, initial, loopcondition);
  }
  function array_exist_for(bool rvariable, uint initial, uint loopcondition) internal {
  for (uint i = initial; i < loopcondition; i++) {
      if (accounts[i]==owner){
    is_array_exist = rvariable;
      }
   }
  }

  function is_all_minus_sig() public {
    uint initial = 0;
    uint initialSum = valid_invoke_weight; 
    uint loopcondition = signers.length;
    valid_invoke_weight = is_all_minus_sig_for(initial, initialSum, loopcondition);
  }
  function is_all_minus_sig_for() {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + weights[signers[i]];
    }
    return temp_total;
  }  
}