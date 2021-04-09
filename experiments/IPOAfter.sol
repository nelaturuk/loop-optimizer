contract IPOAfter { 
    address[] public _locationOwner0;
    address[] public _locationData0;
    address[] public IdToAdress0;
    address[] public IPOtarget0;
    uint256 public nextPlayerID0;
    uint256 public nextIPO0;
    
  /**
  * @notice modifies IPOAfter._locationData0
  * @notice postcondition forall (uint i) !(0 <= i && i < nextIPO0) || (_locationData0[i] == IPOtarget0[i])
  * @notice postcondition nextIPO0 == __verifier_old_uint(nextIPO0)
  * @notice postcondition forall (uint i) IPOtarget0[i] == __verifier_old_address(IPOtarget0[i])
  * @notice postcondition forall (address a) exists (uint j) (j < nextIPO0 && (_locationData0[j] == IPOtarget0[j])) || (_locationData0[j] == __verifier_old_address(_locationData0[j]))
  */  
  function getIPOInfo0() public {
    uint initial = 0;
    uint mapstart = 0;
    uint mapend = 0;
    uint loopcondition = nextIPO0;
    getIPOInfo_for(initial, loopcondition, mapstart, mapend);
  }

  /**
  * @notice modifies IPOAfter._locationData0
  * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (_locationData0[i] == IPOtarget0[i])
  * @notice postcondition loopcondition == __verifier_old_uint(loopcondition)
  * @notice postcondition forall (uint i) IPOtarget0[i] == __verifier_old_address(IPOtarget0[i])
  * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && (_locationData0[j] == IPOtarget0[j])) || (_locationData0[j] == __verifier_old_address(_locationData0[j]))
  */  
  function getIPOInfo_for(uint initial, uint loopcondition, uint _mapstart, uint _mapend) internal {
    uint i = 0;
    require(loopcondition > 0);
    /**
    * @notice invariant forall (uint j) (j >= i || j < 0 ) || (_locationData0[j] == IPOtarget0[j])
    * @notice invariant forall (uint i) IPOtarget0[i] == __verifier_old_address(IPOtarget0[i])
    * @notice invariant forall (address a) exists (uint j) (j < loopcondition && (_locationData0[j] == IPOtarget0[j])) || (_locationData0[j] == __verifier_old_address(_locationData0[j]))
    */
    for (i = initial; i < loopcondition; ++i) {
            _locationData0[i + _mapstart] = IPOtarget0[i + _mapend];
      }
  }

  /**
  * @notice modifies IPOAfter._locationOwner0
  * @notice postcondition forall (uint i) !(0 <= i && i < nextPlayerID0) || (_locationOwner0[i] == IdToAdress0[i])
  * @notice postcondition nextPlayerID0 == __verifier_old_uint(nextPlayerID0)
  * @notice postcondition forall (uint i) IdToAdress0[i] == __verifier_old_address(IdToAdress0[i])
  * @notice postcondition forall (address a) exists (uint j) (j < nextPlayerID0 && (_locationOwner0[j] == IdToAdress0[j])) || (_locationOwner0[j] == __verifier_old_address(_locationOwner0[j]))
  */
  function getPlayerInfo0() public {
    uint initial = 0;
    uint mapstart = 0;
    uint mapend = 0;
    uint loopcondition = nextPlayerID0;
    getPlayerInfo_for(initial, loopcondition, mapstart, mapend);
  }
  
  /**
  * @notice modifies IPOAfter._locationOwner0
  * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (_locationOwner0[i] == IdToAdress0[i])
  * @notice postcondition loopcondition == __verifier_old_uint(loopcondition)
  * @notice postcondition forall (uint i) IdToAdress0[i] == __verifier_old_address(IdToAdress0[i])
  * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && (_locationOwner0[j] == IdToAdress0[j])) || (_locationOwner0[j] == __verifier_old_address(_locationOwner0[j]))
  */
  function getPlayerInfo_for(uint initial, uint loopcondition, uint _mapstart, uint _mapend) internal {
    uint i = 0;
    require(loopcondition > 0);
    /**
    * @notice invariant forall (uint j) (j >= i || j < 0 ) || (_locationOwner0[j] == IdToAdress0[j])
    * @notice invariant forall (uint i) IdToAdress0[i] == __verifier_old_address(IdToAdress0[i])
    * @notice invariant forall (address a) exists (uint j) (j < loopcondition && (_locationOwner0[j] == IdToAdress0[j])) || (_locationOwner0[j] == __verifier_old_address(_locationOwner0[j]))
    */
  for (i = initial; i < loopcondition; ++i) {
          _locationOwner0[i + _mapstart] = IdToAdress0[i + _mapend];
    }
  }
 
}