contract WrappedNFTLiquidationProxyBefore {

    uint256 public _numTokensToPurchase;
    uint256[] public tokenIds;
    uint256[] public tokenIds1;
    uint256[] public _nftIds;
    address[] public destinationAddresses;
    bool public _isMixedBatchOfNFTs;
   
    /**
     * @notice modifies WrappedNFTLiquidationProxyBefore.destinationAddresses
     * @notice postcondition forall (uint i) !(0 <= i && i < _numTokensToPurchase) || (destinationAddresses[i] == msg.sender)
     * @notice postcondition _numTokensToPurchase == __verifier_old_uint(_numTokensToPurchase)
     * @notice postcondition exists (uint j) (j < _numTokensToPurchase) || (destinationAddresses[j] == __verifier_old_address(destinationAddresses[j]))
     */
   function purchaseNFTsAssignSender() public{
       uint i = 0;
       require(_numTokensToPurchase > 0);
         /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (destinationAddresses[j] == msg.sender)
         * @notice invariant !(i == _numTokensToPurchase) || (destinationAddresses[i-1] == msg.sender)
         * @notice invariant forall (address a) exists (uint j) (j < _numTokensToPurchase) || (destinationAddresses[j] == __verifier_old_address(destinationAddresses[j]))
         */
        for(i = 0; i < _numTokensToPurchase; i++){
            destinationAddresses[i] = msg.sender;
        }
    }

     /**
     * @notice modifies WrappedNFTLiquidationProxyBefore.tokenIds
     * @notice postcondition forall (uint i) !(0 <= i && i < _numTokensToPurchase) || (tokenIds[i] == 0)
     * @notice postcondition _numTokensToPurchase == __verifier_old_uint(_numTokensToPurchase)
     * @notice postcondition exists (uint j) (j < _numTokensToPurchase) || (tokenIds[j] == __verifier_old_uint(tokenIds[j]))
     */
    function purchaseNFTsAssignConstant() public {
        uint i = 0;
       require(_numTokensToPurchase > 0);
         /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (tokenIds[j] == 0)
         * @notice invariant !(i == _numTokensToPurchase) || (tokenIds[i-1] == 0)
         * @notice invariant forall (address a) exists (uint j) (j < _numTokensToPurchase) || (tokenIds[j] == __verifier_old_uint(tokenIds[j]))
         */
        for(i = 0; i < _numTokensToPurchase; i++){
            tokenIds[i] = 0;
        }
    }

    /**
        * @notice modifies WrappedNFTLiquidationProxyBefore._nftIds
        * @notice postcondition forall (uint i) !(0 <= i && i < tokenIds1.length  && _isMixedBatchOfNFTs == true) || (_nftIds[i] == tokenIds1[i])
        * @notice postcondition tokenIds1.length == __verifier_old_uint(tokenIds1.length)
        * @notice postcondition forall (uint i) tokenIds1[i] == __verifier_old_uint(tokenIds1[i])
        * @notice postcondition forall (address a) exists (uint j) (j < tokenIds1.length && _isMixedBatchOfNFTs == true && (_nftIds[j] == tokenIds1[j])) || (_nftIds[j] == __verifier_old_uint(_nftIds[j]))
        */ 
    function wrapNFTs() public {
        uint i = 0;
        require(tokenIds1.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (_nftIds[j] == tokenIds1[j]) || _isMixedBatchOfNFTs == false
         * @notice invariant forall (uint i) tokenIds1[i] == __verifier_old_uint(tokenIds1[i])
         * @notice invariant forall (address a) exists (uint j) (j < tokenIds1.length && _isMixedBatchOfNFTs == true && (_nftIds[j] == tokenIds1[j])) || (_nftIds[j] == __verifier_old_uint(_nftIds[j])) 
         */
        for(i = 0; i < tokenIds1.length; i++){
            if(_isMixedBatchOfNFTs){
                _nftIds[i] = tokenIds1[i];
            }
        }
    }
}