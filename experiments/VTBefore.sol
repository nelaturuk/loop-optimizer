contract VTBefore {
    struct PC {
        uint256 lockingPeriod;
        uint256 coins;
        bool added;
    }
    PC[] record; // this will keep record of Locking periods and coins per address

    /**
     * @notice modifies VTBefore.record
     * @notice postcondition forall (uint i) !(0 <= i && i < record.length && record[i].lockingPeriod < now && record[i].added == false) || (record[i].added == true)
     * @notice postcondition record.length == __verifier_old_uint(record.length)
     * @notice postcondition exists (uint j) (j < record.length && record[j].lockingPeriod < now && record[j].added == false) || (record[j].added == __verifier_old_bool(record[j].added))
     */
    function _updateRecord() public {
        uint256 i = 0;
        require(record.length > 0);
        /**
         * @notice invariant forall (uint j) (j >= i || j < 0 ) || (record[j].added == true) || !(record[i].lockingPeriod < now && record[i].added == false)
         * @notice invariant !(i == record.length) || (record[i-1].added == true) || (record[i].added == __verifier_old_bool(record[i].added))
         * @notice invariant exists (uint j) (j < record.length && record[j].lockingPeriod < now && record[j].added == false) || (record[j].added == __verifier_old_bool(record[j].added))
         */
        for (i = 0; i < record.length; i++) {
            if (record[i].lockingPeriod < now && record[i].added == false) {
                record[i].added = true;
            }
        }
    }
}
