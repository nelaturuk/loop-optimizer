contract IPOBefore  {
    address[] public _locationOwner;
    address[] public _locationData;
    address[] public IdToAdress;
    address[] public IPOtarget;
    bool checkpoint;
    uint256 public nextPlayerID;
    uint256 public nextIPO;

        /**
        * @notice modifies IPOBefore._locationOwner
        * @notice postcondition forall (uint i) !(0 <= i && i < nextPlayerID) || (_locationOwner[i] == IdToAdress[i])
        * @notice postcondition nextPlayerID == __verifier_old_uint(nextPlayerID)
        * @notice postcondition forall (uint i) IdToAdress[i] == __verifier_old_address(IdToAdress[i])
        * @notice postcondition forall (address a) exists (uint j) (j < nextPlayerID && (_locationOwner[j] == IdToAdress[j])) || (_locationOwner[j] == __verifier_old_address(_locationOwner[j]))
        */    
        function getPlayerInfo() public{
            uint i = 0;
            require(nextPlayerID > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (_locationOwner[j] == IdToAdress[j])
         * @notice invariant forall (uint i) IdToAdress[i] == __verifier_old_address(IdToAdress[i])
         * @notice invariant forall (address a) exists (uint j) (j < nextPlayerID && (_locationOwner[j] == IdToAdress[j])) || (_locationOwner[j] == __verifier_old_address(_locationOwner[j]))
         */
          for(i = 0; i < nextPlayerID; i++){
                _locationOwner[i] = IdToAdress[i];
            }
        }

        /**
        * @notice modifies IPOBefore._locationData
        * @notice postcondition forall (uint i) !(0 <= i && i < nextIPO) || (_locationData[i] == IPOtarget[i])
        * @notice postcondition nextIPO == __verifier_old_uint(nextIPO)
        * @notice postcondition forall (uint i) IPOtarget[i] == __verifier_old_address(IPOtarget[i])
        * @notice postcondition forall (address a) exists (uint j) (j < nextIPO && (_locationData[j] == IPOtarget[j])) || (_locationData[j] == __verifier_old_address(_locationData[j]))
        */ 
        function getIPOInfo() public {
            uint i = 0;
            require(nextIPO > 0);
            /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (_locationData[j] == IPOtarget[j])
         * @notice invariant forall (uint i) IPOtarget[i] == __verifier_old_address(IPOtarget[i])
         * @notice invariant forall (address a) exists (uint j) (j < nextIPO && (_locationData[j] == IPOtarget[j])) || (_locationData[j] == __verifier_old_address(_locationData[j]))
         */
          for(i = 0; i < nextIPO; i++){
                _locationData[i] = IPOtarget[i];
            }
        }
}