pragma solidity ^0.5.8;
contract WrappedCFBefore {

    uint256[] public depositedChainFacesArray;
    mapping (uint256 => bool) public chainFaceIsDepositedInContract;
    uint256[] public _chainFaceIds;
    
    /**
        * @notice modifies WrappedCFBefore.depositedChainFacesArray
        * @notice postcondition forall (uint i) !(0 <= i && i < _chainFaceIds.length) || (depositedChainFacesArray[i] == _chainFaceIds[i])
        * @notice postcondition _chainFaceIds.length == __verifier_old_uint(_chainFaceIds.length)
        * @notice postcondition forall (uint i) _chainFaceIds[i] == __verifier_old_uint(_chainFaceIds[i])
        * @notice postcondition exists (uint j) (j < _chainFaceIds.length && (depositedChainFacesArray[j] == _chainFaceIds[j])) || (depositedChainFacesArray[j] == __verifier_old_uint(depositedChainFacesArray[j]))
        */ 
    function depositChainFacesAndMintTokens() public {
         uint i = 0;
        require(_chainFaceIds.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (depositedChainFacesArray[j] == _chainFaceIds[j])
         * @notice invariant forall (uint i) _chainFaceIds[i] == __verifier_old_uint(_chainFaceIds[i])
         * @notice invariant exists (uint j) (j < _chainFaceIds.length && (depositedChainFacesArray[j] == _chainFaceIds[j])) || (depositedChainFacesArray[j] == __verifier_old_uint(depositedChainFacesArray[j])) 
         */
        for(i = 0; i < _chainFaceIds.length; i++){
            depositedChainFacesArray[i] = _chainFaceIds[i];
        }
    }
    
    /**
     * @notice modifies WrappedCFBefore.chainFaceIsDepositedInContract
     * @notice postcondition forall (uint i) !(0 <= i && i < _chainFaceIds.length) || (chainFaceIsDepositedInContract[_chainFaceIds[i]] == true)
     * @notice postcondition _chainFaceIds.length == __verifier_old_uint(_chainFaceIds.length)
     * @notice postcondition forall (uint i) _chainFaceIds[i] == __verifier_old_uint(_chainFaceIds[i])
     * @notice postcondition forall (uint a) exists (uint j) (j < _chainFaceIds.length && a == _chainFaceIds[j]) || (chainFaceIsDepositedInContract[a] == __verifier_old_bool(chainFaceIsDepositedInContract[a]))
     */
    function ChainFacesMintTokens() public {
        uint i = 0;
       require(_chainFaceIds.length > 0);
         /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (chainFaceIsDepositedInContract[_chainFaceIds[j]] == true)
         * @notice invariant !(i == _chainFaceIds.length) || (chainFaceIsDepositedInContract[_chainFaceIds[i-1]] == true)
         * @notice invariant forall (uint j) _chainFaceIds[j] == __verifier_old_uint(_chainFaceIds[j])
         * @notice invariant forall (uint a) exists (uint j) (j < _chainFaceIds.length && a == _chainFaceIds[j]) || (chainFaceIsDepositedInContract[a] == __verifier_old_bool(chainFaceIsDepositedInContract[a]))
         */
        for(i = 0; i < _chainFaceIds.length; i++){
            chainFaceIsDepositedInContract[_chainFaceIds[i]] = true; 
        }
    }

    /**
     * @notice modifies WrappedCFBefore.chainFaceIsDepositedInContract
     * @notice postcondition forall (uint i) !(0 <= i && i < _chainFaceIds.length && _chainFaceIds[i] != 0) || (chainFaceIsDepositedInContract[_chainFaceIds[i]] == false) || (chainFaceIsDepositedInContract[_chainFaceIds[i]] == __verifier_old_bool(chainFaceIsDepositedInContract[_chainFaceIds[i]]))
     * @notice postcondition _chainFaceIds.length == __verifier_old_uint(_chainFaceIds.length)
     * @notice postcondition forall (uint i) _chainFaceIds[i] == __verifier_old_uint(_chainFaceIds[i])
     * @notice postcondition forall (uint a) exists (uint j) (j < _chainFaceIds.length && _chainFaceIds[j] != 0 && a == _chainFaceIds[j]) || (chainFaceIsDepositedInContract[a] == __verifier_old_bool(chainFaceIsDepositedInContract[a]))
     */
    function burnTokensAndWithdrawChainFaces() public {
        uint i = 0;
       require(_chainFaceIds.length > 0);
         /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (chainFaceIsDepositedInContract[_chainFaceIds[j]] == false) || (chainFaceIsDepositedInContract[_chainFaceIds[j]] == __verifier_old_bool(chainFaceIsDepositedInContract[_chainFaceIds[j]]))
         * @notice invariant !(i == _chainFaceIds.length && _chainFaceIds[i-1] != 0) || (chainFaceIsDepositedInContract[_chainFaceIds[i-1]] == false) 
         * @notice invariant forall (uint j) _chainFaceIds[j] == __verifier_old_uint(_chainFaceIds[j])
         * @notice invariant forall (uint a) exists (uint j) (j < _chainFaceIds.length && _chainFaceIds[j] != 0 && a == _chainFaceIds[j]) || (chainFaceIsDepositedInContract[a] == __verifier_old_bool(chainFaceIsDepositedInContract[a]))
         */
        for(i = 0; i < _chainFaceIds.length; i++){
            if(_chainFaceIds[i] != 0){
                chainFaceIsDepositedInContract[_chainFaceIds[i]] = false;
            }
        }
    }
}