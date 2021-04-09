// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

contract UnOptimized {
    mapping(address => bool) public whitelist0;
    address[] public _beneficiaries0;
    uint256[] public _tokens0;
    uint256 public total0 = 0;

    /**
     * @notice modifies UnOptimized.whitelist0
     * @notice postcondition forall (uint i) !(0 <= i && i < _beneficiaries0.length) || (whitelist0[_beneficiaries0[i]] == true)
     * @notice postcondition _beneficiaries0.length == __verifier_old_uint(_beneficiaries0.length)
     * @notice postcondition forall (uint i) _beneficiaries0[i] == __verifier_old_address(_beneficiaries0[i])
     * @notice postcondition forall (address a) exists (uint j) (j < _beneficiaries0.length && a == _beneficiaries0[j]) || (whitelist0[a] == __verifier_old_bool(whitelist0[a]))
     */
    function testfn1() public {
        uint256 i = 0;
        require(_beneficiaries0.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (whitelist0[_beneficiaries0[j]] == true)
         * @notice invariant !(i == _beneficiaries0.length) || (whitelist0[_beneficiaries0[i-1]] == true)
         * @notice invariant forall (uint j) _beneficiaries0[j] == __verifier_old_address(_beneficiaries0[j])
         * @notice invariant forall (address a) exists (uint j) (j < _beneficiaries0.length && a == _beneficiaries0[j]) || (whitelist0[a] == __verifier_old_bool(whitelist0[a]))
         */
        for (i = 0; i < _beneficiaries0.length; i++) {
            whitelist0[_beneficiaries0[i]] = true;
        }
    }

    /**
     * @notice modifies total0
     * @notice postcondition total0 >= __verifier_old_uint(total0)
     * @notice postcondition total0 == __verifier_old_uint(total0) + __verifier_sum_uint(_tokens0)
     */
    function testfn2() public {
        uint256 i = 0;
        require(_tokens0.length > 0);
        /**
         * @notice invariant total0 >= __verifier_old_uint(total0)
         * @notice invariant total0 == __verifier_old_uint(total0) + sum(_tokens0[0] ... _tokens0[i])
         */
        for (i = 0; i < _tokens0.length; i++) {
            total0 = ((total0) + (_tokens0[i]));
        }
    }
}
