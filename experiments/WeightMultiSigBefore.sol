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

  function array_exist (){
    for (uint i = 0; i< signers.length;i++){
      if (accounts[i]==owner){
        is_array_exist=true;
      }
    }
  }

  function is_all_minus_sig(uint number, uint64 id, string memory name, bytes32 hash, address sender) internal returns (bool){
    for(uint i = 0; i < signers.length; i++){
      valid_invoke_weight += weights[signers[i]];
    }
  }
}