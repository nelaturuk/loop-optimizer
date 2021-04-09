contract WrappedNFTLiquidationProxyAfter {
    uint256 public _numTokensToPurchase0;
    uint256[] public tokenIds0;
    uint256[] public tokenIds10;
    uint256[] public _nftIds0;
    address[] public destinationAddresses0;
    bool public _isMixedBatchOfNFTs0;

    /**
     * @notice modifies WrappedNFTLiquidationProxyAfter.destinationAddresses0
     * @notice postcondition forall (uint i) !(0 <= i && i < _numTokensToPurchase0) || (destinationAddresses0[i] == msg.sender)
     * @notice postcondition _numTokensToPurchase0 == __verifier_old_uint(_numTokensToPurchase0)
     * @notice postcondition exists (uint j) (j < _numTokensToPurchase0) || (destinationAddresses0[j] == __verifier_old_address(destinationAddresses0[j]))
     */
    function purchaseNFTsAssignSender0() public {
        address rvariable = msg.sender;
        uint256 initial = 0;
        uint256 loopcondition = _numTokensToPurchase0;
        purchaseNFTsAssignSender_for(rvariable, initial, loopcondition);
    }

    /**
     * @notice modifies WrappedNFTLiquidationProxyAfter.destinationAddresses0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (destinationAddresses0[i] == rvariable)
     * @notice postcondition loopcondition == __verifier_old_uint(loopcondition)
     * @notice postcondition exists (uint j) (j < loopcondition) || (destinationAddresses0[j] == __verifier_old_address(destinationAddresses0[j]))
     */
    function purchaseNFTsAssignSender_for(
        address rvariable,
        uint256 initial,
        uint256 loopcondition
    ) internal {
        uint256 i = 0;
        require(loopcondition > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (destinationAddresses0[j] == rvariable)
         * @notice invariant !(i == _numTokensToPurchase0) || (destinationAddresses0[i-1] == rvariable)
         * @notice invariant forall (address a) exists (uint j) (j < _numTokensToPurchase0) || (destinationAddresses0[j] == __verifier_old_address(destinationAddresses0[j]))
         */
        for (i = initial; i < loopcondition; i++) {
            destinationAddresses0[i] = rvariable;
        }
    }

    /**
     * @notice modifies WrappedNFTLiquidationProxyAfter._nftIds0
     * @notice postcondition forall (uint i) !(0 <= i && i < tokenIds10.length  && _isMixedBatchOfNFTs0 == true) || (_nftIds0[i] == tokenIds10[i])
     * @notice postcondition tokenIds10.length == __verifier_old_uint(tokenIds10.length)
     * @notice postcondition forall (uint i) tokenIds10[i] == __verifier_old_uint(tokenIds10[i])
     * @notice postcondition forall (address a) exists (uint j) (j < tokenIds10.length && _isMixedBatchOfNFTs0 == true && (_nftIds0[j] == tokenIds10[j])) || (_nftIds0[j] == __verifier_old_uint(_nftIds0[j]))
     */

    function wrapNFTs0() public {
        uint256 initial = 0;
        uint256 mapstart = 0;
        uint256 mapend = 0;
        uint256 loopcondition = tokenIds10.length;
        wrapNFTs_for(initial, loopcondition, mapstart, mapend);
    }

    /**
     * @notice modifies WrappedNFTLiquidationProxyAfter._nftIds0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition  && _isMixedBatchOfNFTs0 == true) || (_nftIds0[i] == tokenIds10[i])
     * @notice postcondition loopcondition == __verifier_old_uint(loopcondition)
     * @notice postcondition forall (uint i) tokenIds10[i] == __verifier_old_uint(tokenIds10[i])
     * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && _isMixedBatchOfNFTs0 == true && (_nftIds0[j] == tokenIds10[j])) || (_nftIds0[j] == __verifier_old_uint(_nftIds0[j]))
     */
    function wrapNFTs_for(
        uint256 initial,
        uint256 loopcondition,
        uint256 _mapstart,
        uint256 _mapend
    ) internal {
        uint256 i = 0;
        require(loopcondition > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (_nftIds0[j] == tokenIds10[j]) || _isMixedBatchOfNFTs0 == false
         * @notice invariant forall (uint i) tokenIds10[i] == __verifier_old_uint(tokenIds10[i])
         * @notice invariant forall (address a) exists (uint j) (j < tokenIds10.length && _isMixedBatchOfNFTs0 == true && (_nftIds0[j] == tokenIds10[j])) || (_nftIds0[j] == __verifier_old_uint(_nftIds0[j]))
         */
        for (i = initial; i < loopcondition; ++i) {
          if(_isMixedBatchOfNFTs0){
            _nftIds0[i + _mapstart] = tokenIds10[i + _mapend];
          }
        }
    }

    /**
     * @notice modifies WrappedNFTLiquidationProxyAfter.tokenIds0
     * @notice postcondition forall (uint i) !(0 <= i && i < _numTokensToPurchase0) || (tokenIds0[i] == 0)
     * @notice postcondition _numTokensToPurchase0 == __verifier_old_uint(_numTokensToPurchase0)
     * @notice postcondition exists (uint j) (j < _numTokensToPurchase0) || (tokenIds0[j] == __verifier_old_uint(tokenIds0[j]))
     */
    function purchaseNFTsAssignConstant0() public {
        uint256 rvariable = 0;
        uint256 initial = 0;
        uint256 loopcondition = _numTokensToPurchase0;
        purchaseNFTsAssignConstant_for(rvariable, initial, loopcondition);
    }

    /**
     * @notice modifies WrappedNFTLiquidationProxyAfter.tokenIds0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (tokenIds0[i] == rvariable)
     * @notice postcondition loopcondition == __verifier_old_uint(loopcondition)
     * @notice postcondition exists (uint j) (j < loopcondition) || (tokenIds0[j] == __verifier_old_uint(tokenIds0[j]))
     */
    function purchaseNFTsAssignConstant_for(
        uint256 rvariable,
        uint256 initial,
        uint256 loopcondition
    ) internal {
        uint256 i = 0;
        require(loopcondition > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (tokenIds0[j] == rvariable)
         * @notice invariant !(i == loopcondition) || (tokenIds0[i-1] == rvariable)
         * @notice invariant forall (address a) exists (uint j) (j < loopcondition) || (tokenIds0[j] == __verifier_old_uint(tokenIds0[j]))
         */
        for (i = initial; i < loopcondition; i++) {
            tokenIds0[i] = rvariable;
        }
    }
}
