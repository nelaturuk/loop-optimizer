contract ERC1155 is ERC165, IERC1155
{
    using SafeMath for uint256;
    using Address for address;

    // Mapping from token ID to owner balances
    mapping (uint256 => mapping(address => uint256)) private _balances;

    // Mapping from owner to operator approvals
    mapping (address => mapping(address => bool)) private _operatorApprovals;
    uint256[] batchBalances;
    address[] owners;
    uint256[]  ids;
    uint256[]  values;
    address to;

    function balanceOfBatch() public {
    bool rvariable = true; 
    uint loopcondition = owners.length;
    transferBeneficiaryShipWithHowMany_for(rvariable, loopcondition);
  }
  function balanceOfBatch_for(bool rvariable, uint loopcondition) internal {
  for (uint i = 0; i < loopcondition; i++) {
    batchBalances[i] = _balances[ids[i]][owners[i]];
   }
  }

  function _batchMint() public {
    bool rvariable = true; 
    uint loopcondition = ids.length;
    transferBeneficiaryShipWithHowMany_for(rvariable, loopcondition);
  }
  function _batchMint_for(bool rvariable, uint loopcondition) internal {
  for (uint i = 0; i < loopcondition; i++) {
    _balances[ids[i]][to] = values[i] + _balances[ids[i]][to];
   }
  }

  function _batchBurn() public {
    bool rvariable = true; 
    uint loopcondition = ids.length;
    transferBeneficiaryShipWithHowMany_for(rvariable, loopcondition);
  }
  function _batchBurn_for(bool rvariable, uint loopcondition) internal {
  for (uint i = 0; i < loopcondition; i++) {
    _balances[ids[i]][to] = _balances[ids[i]][to] - values[i];
   }
  }
}