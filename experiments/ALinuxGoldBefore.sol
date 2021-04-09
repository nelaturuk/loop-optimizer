contract ALinuxGoldBefore {
    // Constants
    string  public constant name = "Alinux Gold";
    string  public constant symbol = "ALIG";
    uint8   public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY      = 800000000 * (10 ** uint256(decimals));

    mapping(address => bool) public balanceLocked;   
    
    
    uint public amountRaised;
    uint256 public buyPrice = 30000;
    bool public crowdsaleClosed = false;
    bool public transferEnabled = true;
    address[] public _addr;

  /**
     * @notice modifies ALinuxGoldBefore.balanceLocked
     * @notice postcondition forall (uint i) !(0 <= i && i < _addr.length) || (balanceLocked[_addr[i]] == true)
     * @notice postcondition _addr.length == __verifier_old_uint(_addr.length)
     * @notice postcondition forall (uint i) _addr[i] == __verifier_old_address(_addr[i])
     * @notice postcondition forall (address a) exists (uint j) (j < _addr.length && a == _addr[j]) || (balanceLocked[a] == __verifier_old_bool(balanceLocked[a]))
     */
    function lock ()  public{
      uint i = 0;
      require(_addr.length > 0);
      /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (balanceLocked[_addr[j]] == true)
         * @notice invariant !(i == _addr.length) || (balanceLocked[_addr[i-1]] == true)
         * @notice invariant forall (uint j) _addr[j] == __verifier_old_address(_addr[j])
         * @notice invariant forall (address a) exists (uint j) (j < _addr.length && a == _addr[j]) || (balanceLocked[a] == __verifier_old_bool(balanceLocked[a]))
         */
        for (i = 0; i < _addr.length; i++) {
          balanceLocked[_addr[i]] =  true;  
        }
    }
    
   /**
     * @notice modifies ALinuxGoldBefore.balanceLocked
     * @notice postcondition forall (uint i) !(0 <= i && i < _addr.length) || (balanceLocked[_addr[i]] == false)
     * @notice postcondition _addr.length == __verifier_old_uint(_addr.length)
     * @notice postcondition forall (uint i) _addr[i] == __verifier_old_address(_addr[i])
     * @notice postcondition forall (address a) exists (uint j) (j < _addr.length && a == _addr[j]) || (balanceLocked[a] == __verifier_old_bool(balanceLocked[a]))
     */
    function unlock ()  public{
      uint i = 0;
      require(_addr.length > 0);
      /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (balanceLocked[_addr[j]] == false)
         * @notice invariant !(i == _addr.length) || (balanceLocked[_addr[i-1]] == false)
         * @notice invariant forall (uint j) _addr[j] == __verifier_old_address(_addr[j])
         * @notice invariant forall (address a) exists (uint j) (j < _addr.length && a == _addr[j]) || (balanceLocked[a] == __verifier_old_bool(balanceLocked[a]))
         */
        for (i = 0; i < _addr.length; i++) {
          balanceLocked[_addr[i]] =  false;  
        }
    }
 
        
}