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

    function balanceOfBatch( )
    {
        for (uint256 i = 0; i < owners.length; ++i) {
            batchBalances[i] = _balances[ids[i]][owners[i]];
        }
    }
    
    function safeBatchTransferFrom()
    {
        for (uint256 i = 0; i < ids.length; ++i) {
            _balances[i][to] = value + _balances[id][to];
        }
    }
    function _batchMint() {
        for(uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = values[i] + _balances[ids[i]][to];
        }
    }
    function _batchBurn() internal {
        for(uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = _balances[ids[i]][to] - values[i];
        }
    }
}