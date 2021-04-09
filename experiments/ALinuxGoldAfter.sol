contract ALinuxGoldAfter { 
    string  public constant name0 = "Alinux Gold";
    string  public constant symbol0 = "ALIG";
    uint8   public constant decimals0 = 18;
    uint256 public constant INITIAL_SUPPLY0    = 800000000 * (10 ** uint256(decimals0));
    mapping(address => bool) public balanceLocked0;   
    uint public amountRaised0;
    uint256 public buyPrice0 = 30000;
    bool public crowdsaleClosed0 = false;
    bool public transferEnabled0 = true;
    address[] public _addr0;

    /**
     * @notice modifies ALinuxGoldAfter.balanceLocked0
     * @notice postcondition forall (uint i) !(0 <= i && i < _addr0.length) || (balanceLocked0[_addr0[i]] == false)
     * @notice postcondition forall (uint j) _addr0[j] == __verifier_old_address(_addr0[j])
     * @notice postcondition _addr0.length == __verifier_old_uint(_addr0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < _addr0.length && a == _addr0[j]) || (balanceLocked0[a] == __verifier_old_bool(balanceLocked0[a]))
     */
  function unlock0() public {
    bool rvariable = false; 
    uint loopcondition = _addr0.length;
    unlock_for(rvariable, loopcondition);
  }

  /**
     * @notice modifies ALinuxGoldAfter.balanceLocked0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (balanceLocked0[_addr0[i]] == rvariable)
     * @notice postcondition forall (uint j) _addr0[j] == __verifier_old_address(_addr0[j])
     * @notice postcondition _addr0.length == __verifier_old_uint(_addr0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && a == _addr0[j]) || (balanceLocked0[a] == __verifier_old_bool(balanceLocked0[a]))
     */
  function unlock_for(bool rvariable, uint loopcondition) internal {
    uint i = 0;
      require(loopcondition > 0);
     /**
             * @notice invariant forall (uint j) (j >= i || j < 0 ) || (balanceLocked0[_addr0[j]] == rvariable)
             * @notice invariant !(i == loopcondition) || (balanceLocked0[_addr0[i-1]] == rvariable)
             * @notice invariant forall (uint j) _addr0[j] == __verifier_old_address(_addr0[j])
             * @notice invariant forall (address a) exists (uint j) (j < loopcondition && a == _addr0[j]) || (balanceLocked0[a] == __verifier_old_bool(balanceLocked0[a]))
             */
  for (i = 0; i < loopcondition; i++) {
    balanceLocked0[_addr0[i]] = rvariable;
   }
  }

  /**
     * @notice modifies ALinuxGoldAfter.balanceLocked0
     * @notice postcondition forall (uint i) !(0 <= i && i < _addr0.length) || (balanceLocked0[_addr0[i]] == true)
     * @notice postcondition forall (uint j) _addr0[j] == __verifier_old_address(_addr0[j])
     * @notice postcondition _addr0.length == __verifier_old_uint(_addr0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < _addr0.length && a == _addr0[j]) || (balanceLocked0[a] == __verifier_old_bool(balanceLocked0[a]))
     */
  function lock0() public {
    bool rvariable = true; 
    uint loopcondition = _addr0.length;
    lock_for(rvariable, loopcondition);
  }

   /**
     * @notice modifies ALinuxGoldAfter.balanceLocked0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (balanceLocked0[_addr0[i]] == rvariable)
     * @notice postcondition forall (uint j) _addr0[j] == __verifier_old_address(_addr0[j])
     * @notice postcondition _addr0.length == __verifier_old_uint(_addr0.length)
     * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && a == _addr0[j]) || (balanceLocked0[a] == __verifier_old_bool(balanceLocked0[a]))
     */
  function lock_for(bool rvariable, uint loopcondition) internal {
    uint i = 0;
      require(loopcondition > 0);
     /**
             * @notice invariant forall (uint j) (j >= i || j < 0 ) || (balanceLocked0[_addr0[j]] == rvariable)
             * @notice invariant !(i == loopcondition) || (balanceLocked0[_addr0[i-1]] == rvariable)
             * @notice invariant forall (uint j) _addr0[j] == __verifier_old_address(_addr0[j])
             * @notice invariant forall (address a) exists (uint j) (j < loopcondition && a == _addr0[j]) || (balanceLocked0[a] == __verifier_old_bool(balanceLocked0[a]))
             */
  for (i = 0; i < loopcondition; i++) {
    balanceLocked0[_addr0[i]] = rvariable;
   }
  }
 
}