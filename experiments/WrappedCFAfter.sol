contract WrappedCFAfter {
    uint256[] public depositedChainFacesArray0;
    mapping(uint256 => bool) public chainFaceIsDepositedInContract0;
    uint256[] public _chainFaceIds0;

    /**
     * @notice modifies WrappedCFAfter.depositedChainFacesArray0
     * @notice postcondition forall (uint i) !(0 <= i && i < _chainFaceIds0.length) || (depositedChainFacesArray0[i] == _chainFaceIds0[i])
     * @notice postcondition _chainFaceIds0.length == __verifier_old_uint(_chainFaceIds0.length)
     * @notice postcondition forall (uint i) _chainFaceIds0[i] == __verifier_old_uint(_chainFaceIds0[i])
     * @notice postcondition exists (uint j) (j < _chainFaceIds0.length && (depositedChainFacesArray0[j] == _chainFaceIds0[j])) || (depositedChainFacesArray0[j] == __verifier_old_uint(depositedChainFacesArray0[j]))
     */

    function depositChainFacesAndMintTokens0() public {
        uint256 initial = 0;
        uint256 mapstart = 0;
        uint256 mapend = 0;
        uint256 loopcondition = _chainFaceIds0.length;
        depositChainFacesAndMintTokens_for(
            initial,
            loopcondition,
            mapstart,
            mapend
        );
    }

    /**
     * @notice modifies WrappedCFAfter.depositedChainFacesArray0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (depositedChainFacesArray0[i] == _chainFaceIds0[i])
     * @notice postcondition loopcondition == __verifier_old_uint(loopcondition)
     * @notice postcondition forall (uint i) _chainFaceIds0[i] == __verifier_old_uint(_chainFaceIds0[i])
     * @notice postcondition exists (uint j) (j < loopcondition && (depositedChainFacesArray0[j] == _chainFaceIds0[j])) || (depositedChainFacesArray0[j] == __verifier_old_uint(depositedChainFacesArray0[j]))
     */

    function depositChainFacesAndMintTokens_for(
        uint256 initial,
        uint256 loopcondition,
        uint256 _mapstart,
        uint256 _mapend
    ) internal {
        uint256 i = 0;
        require(loopcondition > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (depositedChainFacesArray0[j] == _chainFaceIds0[j])
         * @notice invariant forall (uint i) _chainFaceIds0[i] == __verifier_old_uint(_chainFaceIds0[i])
         * @notice invariant exists (uint j) (j < loopcondition && (depositedChainFacesArray0[j] == _chainFaceIds0[j])) || (depositedChainFacesArray0[j] == __verifier_old_uint(depositedChainFacesArray0[j]))
         */
        for (i = initial; i < loopcondition; ++i) {
            depositedChainFacesArray0[i + _mapstart] = _chainFaceIds0[
                i + _mapend
            ];
        }
    }

    /**
     * @notice modifies WrappedCFAfter.chainFaceIsDepositedInContract0
     * @notice postcondition forall (uint i) !(0 <= i && i < _chainFaceIds0.length && _chainFaceIds0[i] != 0) || (chainFaceIsDepositedInContract0[_chainFaceIds0[i]] == false) || (chainFaceIsDepositedInContract0[_chainFaceIds0[i]] == __verifier_old_bool(chainFaceIsDepositedInContract0[_chainFaceIds0[i]]))
     * @notice postcondition _chainFaceIds0.length == __verifier_old_uint(_chainFaceIds0.length)
     * @notice postcondition forall (uint i) _chainFaceIds0[i] == __verifier_old_uint(_chainFaceIds0[i])
     * @notice postcondition forall (uint a) exists (uint j) (j < _chainFaceIds0.length && _chainFaceIds0[j] != 0 && a == _chainFaceIds0[j]) || (chainFaceIsDepositedInContract0[a] == __verifier_old_bool(chainFaceIsDepositedInContract0[a]))
     */
    function burnTokensAndWithdrawChainFaces0() public {
        bool rvariable = false;
        uint256 loopcondition = _chainFaceIds0.length;
        burnTokensAndWithdrawChainFaces_for(rvariable, loopcondition);
    }

    /**
     * @notice modifies WrappedCFAfter.chainFaceIsDepositedInContract0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition && _chainFaceIds0[i] != 0) || (chainFaceIsDepositedInContract0[_chainFaceIds0[i]] == false) || (chainFaceIsDepositedInContract0[_chainFaceIds0[i]] == __verifier_old_bool(chainFaceIsDepositedInContract0[_chainFaceIds0[i]]))
     * @notice postcondition loopcondition == __verifier_old_uint(loopcondition)
     * @notice postcondition forall (uint i) _chainFaceIds0[i] == __verifier_old_uint(_chainFaceIds0[i])
     * @notice postcondition forall (uint a) exists (uint j) (j < loopcondition && _chainFaceIds0[j] != 0 && a == _chainFaceIds0[j]) || (chainFaceIsDepositedInContract0[a] == __verifier_old_bool(chainFaceIsDepositedInContract0[a]))
     */
    function burnTokensAndWithdrawChainFaces_for(
        bool rvariable,
        uint256 loopcondition
    ) internal {
        uint256 i = 0;
        require(loopcondition > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (chainFaceIsDepositedInContract0[_chainFaceIds0[j]] == false) || (chainFaceIsDepositedInContract0[_chainFaceIds0[j]] == __verifier_old_bool(chainFaceIsDepositedInContract0[_chainFaceIds0[j]]))
         * @notice invariant !(i == loopcondition && _chainFaceIds0[i-1] != 0) || (chainFaceIsDepositedInContract0[_chainFaceIds0[i-1]] == false)
         * @notice invariant forall (uint j) _chainFaceIds0[j] == __verifier_old_uint(_chainFaceIds0[j])
         * @notice invariant forall (uint a) exists (uint j) (j < loopcondition && _chainFaceIds0[j] != 0 && a == _chainFaceIds0[j]) || (chainFaceIsDepositedInContract0[a] == __verifier_old_bool(chainFaceIsDepositedInContract0[a]))
         */
        for (i = 0; i < loopcondition; i++) {
          if(_chainFaceIds0[i] != 0){
            chainFaceIsDepositedInContract0[_chainFaceIds0[i]] = rvariable;
          }
        }
    }

    /**
     * @notice modifies WrappedCFAfter.chainFaceIsDepositedInContract0
     * @notice postcondition forall (uint i) !(0 <= i && i < _chainFaceIds0.length) || (chainFaceIsDepositedInContract0[_chainFaceIds0[i]] == true)
     * @notice postcondition _chainFaceIds0.length == __verifier_old_uint(_chainFaceIds0.length)
     * @notice postcondition forall (uint i) _chainFaceIds0[i] == __verifier_old_uint(_chainFaceIds0[i])
     * @notice postcondition forall (uint a) exists (uint j) (j < _chainFaceIds0.length && a == _chainFaceIds0[j]) || (chainFaceIsDepositedInContract0[a] == __verifier_old_bool(chainFaceIsDepositedInContract0[a]))
     */
    function ChainFacesMintTokens0() public {
        bool rvariable = true;
        uint256 loopcondition = _chainFaceIds0.length;
        ChainFacesMintTokens_for(rvariable, loopcondition);
    }

    /**
     * @notice modifies WrappedCFAfter.chainFaceIsDepositedInContract0
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (chainFaceIsDepositedInContract0[_chainFaceIds0[i]] == true)
     * @notice postcondition loopcondition == __verifier_old_uint(loopcondition)
     * @notice postcondition forall (uint i) _chainFaceIds0[i] == __verifier_old_uint(_chainFaceIds0[i])
     * @notice postcondition forall (uint a) exists (uint j) (j < loopcondition && a == _chainFaceIds0[j]) || (chainFaceIsDepositedInContract0[a] == __verifier_old_bool(chainFaceIsDepositedInContract0[a]))
     */
    function ChainFacesMintTokens_for(bool rvariable, uint256 loopcondition)
        internal
    {
        uint256 i = 0;
        require(loopcondition > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (chainFaceIsDepositedInContract0[_chainFaceIds0[j]] == true)
         * @notice invariant !(i == loopcondition) || (chainFaceIsDepositedInContract0[_chainFaceIds0[i-1]] == true)
         * @notice invariant forall (uint j) _chainFaceIds0[j] == __verifier_old_uint(_chainFaceIds0[j])
         * @notice invariant forall (uint a) exists (uint j) (j < loopcondition && a == _chainFaceIds0[j]) || (chainFaceIsDepositedInContract0[a] == __verifier_old_bool(chainFaceIsDepositedInContract0[a]))
         */
        for (i = 0; i < loopcondition; i++) {
            chainFaceIsDepositedInContract0[_chainFaceIds0[i]] = rvariable;
        }
    }
}
