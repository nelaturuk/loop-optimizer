contract MultiownableBefore {
    address[] public owners;

    mapping(address => uint256) public ownersIndices; // Star
    address public _newOwner;
    address public _oldOwner;

    /**
     * @notice modifies MultiownableBefore.owners
     * @notice postcondition forall (uint i) !(0 <= i && i < owners.length && _oldOwner == owners[i]) || (owners[i] == _newOwner)  || (owners[i] != _newOwner)
     * @notice postcondition _oldOwner == __verifier_old_address(_oldOwner)
     * @notice postcondition _newOwner == __verifier_old_address(_newOwner)
     */
    function _transferOwnership1() public {
        uint256 i = 0;
        require(owners.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (owners[j] == _newOwner) || (owners[j] != _newOwner)
         * @notice invariant !(i == owners.length && owners[i-1] == _oldOwner) || (owners[i-1] == _newOwner) 
         * @notice postcondition _oldOwner == __verifier_old_address(_oldOwner)
         * @notice invariant _newOwner == __verifier_old_address(_newOwner)
         */
        for (i = 0; i < owners.length; i++) {
            if (_oldOwner == owners[i]) {
                owners[i] = _newOwner;
            }
        }
    }

    // function _transferOwnership3() public {
    //     for (uint256 i = 0; i < owners.length; i++) {
    //         if (_oldOwner == owners[i]) {
    //             ownersIndices[_oldOwner] = 0;
    //         }
    //     }
    // }
}
