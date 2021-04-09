contract MultiownableAfter {
    address[] public owners;
    mapping(address => uint256) public ownersIndices; // Starts from 1
    address public _newOwner;
    address public _oldOwner;

    /**
     * @notice modifies MultiownableAfter.owners
     * @notice postcondition forall (uint i) !(0 <= i && i < owners.length && _oldOwner == owners[i]) || (owners[i] == _newOwner)  || (owners[i] != _newOwner)
     * @notice postcondition _oldOwner == __verifier_old_address(_oldOwner)
     * @notice postcondition _newOwner == __verifier_old_address(_newOwner)
     */
    function _transferOwnership1() public {
        address rvariable = _newOwner;
        uint initial = 0;
        uint loopcondition = owners.length;
        _transferOwnership1_for(rvariable, initial, loopcondition);
    }

    /**
     * @notice modifies MultiownableAfter.owners
     * @notice postcondition forall (uint i) !(initial <= i && i < loopcondition && _oldOwner == owners[i]) || (owners[i] == rvariable)  || (owners[i] != rvariable)
     * @notice postcondition _oldOwner == __verifier_old_address(_oldOwner)
     * @notice postcondition rvariable == __verifier_old_address(rvariable)
     */
    function _transferOwnership1_for(
        address rvariable,
        uint initial,
        uint loopcondition
    ) internal {
        uint i = 0;
        require(initial >= 0);
        require(loopcondition > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < initial ) || (owners[j] == rvariable) || (owners[j] != rvariable)
         * @notice invariant !(i == loopcondition && owners[i-1] == rvariable) || (owners[i-1] == rvariable)
         * @notice postcondition _oldOwner == __verifier_old_address(_oldOwner)
         * @notice invariant rvariable == __verifier_old_address(rvariable)
         */
        for (i = initial; i < loopcondition; i++) {
           if (_oldOwner == owners[i]) {
            owners[i] = rvariable;
           }
        }
    }

    // function _transferOwnership3() public {
    //     uint256 rvariable = 0;
    //     uint256 initial = 0;
    //     uint256 loopcondition = owners.length;
    //     _transferOwnership3_for(rvariable, initial, loopcondition);
    // }

    // function _transferOwnership3_for(
    //     bool rvariable,
    //     uint256 initial,
    //     uint256 loopcondition
    // ) internal {
    //     for (uint256 i = initial; i < loopcondition; i++) {
    //         owners[i] = rvariable;
    //     }
    // }
}
