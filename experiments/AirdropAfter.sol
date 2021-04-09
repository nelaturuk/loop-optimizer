contract AirdropAfter { 
    uint64 public maxClaimedBy0 = 100;
    uint256 public constant MINT_AMOUNT0 = 1010101010101010101010101;
    uint256 public constant CREATOR_AMOUNT0 = (MINT_AMOUNT0 * 6) / 100;
    uint256 public constant SHUFLE_BY_ETH0 = 150;
    uint256 public constant MAX_CLAIM_ETH0 = 10 ether;
    mapping(address => bool) public isSigner0;
    mapping(address => uint256) public claimed0;
    mapping(address => uint256) public numberClaimedBy0;
    bool public creatorClaimed0;
    address[] public _signers0;
    bool public _active0;
     /**
     * @notice modifies AirdropAfter.isSigner0
     * @notice postcondition forall (uint i) !(0 <= i && i < _signers0.length) || (isSigner0[_signers0[i]] == _active0)
     * @notice postcondition forall (uint j) _signers0[j] == __verifier_old_address(_signers0[j])
     * @notice postcondition _signers0.length == __verifier_old_uint(_signers0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < _signers0.length && a == _signers0[j]) || (isSigner0[a] == __verifier_old_bool(isSigner0[a]))
     */
  function setActiveSigners0() public {
    bool rvariable = _active0; 
    uint loopcondition = _signers0.length;
    setActiveSigners_for(rvariable, loopcondition);
  }

   /**
     * @notice modifies AirdropAfter.isSigner0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (isSigner0[_signers0[i]] == rvariable)
     * @notice postcondition forall (uint j) _signers0[j] == __verifier_old_address(_signers0[j])
     * @notice postcondition _signers0.length == __verifier_old_uint(_signers0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && a == _signers0[j]) || (isSigner0[a] == __verifier_old_bool(isSigner0[a]))
     */
  function setActiveSigners_for(bool rvariable, uint loopcondition) internal {
     uint i = 0;
      require(loopcondition > 0);
     /**
             * @notice invariant forall (uint j) (j >= i || j < 0 ) || (isSigner0[_signers0[j]] == rvariable)
             * @notice invariant !(i == loopcondition) || (isSigner0[_signers0[i-1]] == rvariable)
             * @notice invariant forall (uint j) _signers0[j] == __verifier_old_address(_signers0[j])
             * @notice invariant forall (address a) exists (uint j) (j < loopcondition && a == _signers0[j]) || (isSigner0[a] == __verifier_old_bool(isSigner0[a]))
             */
  for ( i = 0; i < loopcondition; i++) {
    isSigner0[_signers0[i]] = rvariable;
   }
  }
 
}