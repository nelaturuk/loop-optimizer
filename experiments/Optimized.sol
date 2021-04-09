// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

contract Optimized {
    mapping(address => bool) public whitelist;
    address[] public _beneficiaries;
    uint256[] public _tokens;
    uint256 public total = 0;

    /**
     * @notice modifies Optimized.total
     * @notice postcondition total >= __verifier_old_uint(total)
     * @notice postcondition total == __verifier_old_uint(total) + __verifier_sum_uint(_tokens)
     */
    function testfn2_1() public {
        uint256 initial = 0;
        uint256 initialSum = total;
        uint256 loopcondition = _tokens.length;
        total = testfn2_1_for(initial, initialSum, loopcondition);
    }

    /**
     * @notice postcondition temp_total >= __verifier_old_uint(temp_total)
     * @notice postcondition loopcondition != _tokens.length || initial != 0 || val == initialSum + __verifier_sum_uint(_tokens)
     */
    function testfn2_1_for(
        uint256 initial,
        uint256 initialSum,
        uint256 loopcondition
    ) public returns (uint256 val) {
        uint256 temp_total = initialSum;
        /**
         * @notice invariant temp_total >= __verifier_old_uint(temp_total)
         * @notice invariant temp_total == __verifier_old_uint(temp_total) + sum(_tokens[0] ... _tokens[i])
         */
        for (uint256 i = initial; i < loopcondition; i++) {
            temp_total = temp_total + _tokens[i];
        }
        return temp_total;
    }

    /**
     * @notice modifies Optimized.whitelist
     * @notice postcondition forall (uint i) !(0 <= i && i < _beneficiaries.length) || (whitelist[_beneficiaries[i]] == true)
     * @notice postcondition forall (uint j) _beneficiaries[j] == __verifier_old_address(_beneficiaries[j])
     * @notice postcondition _beneficiaries.length == __verifier_old_uint(_beneficiaries.length)
     * @notice postcondition forall (address a) exists (uint j) (j < _beneficiaries.length && a == _beneficiaries[j]) || (whitelist[a] == __verifier_old_bool(whitelist[a]))
     */
    function testfn1_0() public {
        bool rvariable = true;
        uint256 loopcondition = _beneficiaries.length;
        testfn1_0_for(rvariable, loopcondition);
    }

    /**
     * @notice modifies Optimized.whitelist
     * @notice postcondition forall (uint i) !(0 <= i && i < loopcondition) || (whitelist[_beneficiaries[i]] == rvariable)
     * @notice postcondition forall (uint j) _beneficiaries[j] == __verifier_old_address(_beneficiaries[j])
     * @notice postcondition _beneficiaries.length == __verifier_old_uint(_beneficiaries.length)
     * @notice postcondition forall (address a) exists (uint j) (j < loopcondition && a == _beneficiaries[j]) || (whitelist[a] == __verifier_old_bool(whitelist[a]))
     */
    function testfn1_0_for(bool rvariable, uint256 loopcondition) internal {
        uint256 i = 0;
        require(loopcondition > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (whitelist[_beneficiaries[j]] == rvariable)
         * @notice invariant !(i == loopcondition) || (whitelist[_beneficiaries[i-1]] == rvariable)
         * @notice invariant forall (uint j) _beneficiaries[j] == __verifier_old_address(_beneficiaries[j])
         * @notice invariant forall (address a) exists (uint j) (j < loopcondition && a == _beneficiaries[j]) || (whitelist[a] == __verifier_old_bool(whitelist[a]))
         */
        for (i = 0; i < loopcondition; i++) {
            whitelist[_beneficiaries[i]] = rvariable;
        }
    }
}

/**
 * @notice invariant i < (initial + 1) || temp_total == __verifier_old_uint(temp_total) + _tokens[i-1]
 */
