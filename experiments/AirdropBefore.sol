contract AirdropBefore {
    uint64 public maxClaimedBy = 100;
    uint256 public constant MINT_AMOUNT = 1010101010101010101010101;
    uint256 public constant CREATOR_AMOUNT = (MINT_AMOUNT * 6) / 100;
    uint256 public constant SHUFLE_BY_ETH = 150;
    uint256 public constant MAX_CLAIM_ETH = 10 ether;

    mapping(address => bool) public isSigner;

    mapping(address => uint256) public claimed;
    mapping(address => uint256) public numberClaimedBy;
    bool public creatorClaimed;
    address[] public _signers;
    bool public _active;

    /**
     * @notice modifies AirdropBefore.isSigner
     * @notice postcondition forall (uint i) !(0 <= i && i < _signers.length) || (isSigner[_signers[i]] == _active)
     * @notice postcondition _signers.length == __verifier_old_uint(_signers.length)
     * @notice postcondition forall (uint i) _signers[i] == __verifier_old_address(_signers[i])
     * @notice postcondition forall (address a) exists (uint j) (j < _signers.length && a == _signers[j]) || (isSigner[a] == __verifier_old_bool(isSigner[a]))
     */
    function setActiveSigners() public{
        uint256 i = 0;
        require(_signers.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (isSigner[_signers[j]] == _active)
         * @notice invariant !(i == _signers.length) || (isSigner[_signers[i-1]] == _active)
         * @notice invariant forall (uint j) _signers[j] == __verifier_old_address(_signers[j])
         * @notice invariant forall (address a) exists (uint j) (j < _signers.length && a == _signers[j]) || (isSigner[a] == __verifier_old_bool(isSigner[a]))
         */
        for (i = 0; i < _signers.length; i++) {
            isSigner[_signers[i]] = _active;
        }
    }
}