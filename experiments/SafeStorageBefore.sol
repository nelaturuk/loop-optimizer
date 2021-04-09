contract SafeStorage  {
    struct LockSlot{
        uint256[] tokens;
        uint256[] periods;
        uint256 paidTokens;
        bool finalized;
    }

    mapping (address => mapping(uint256 => LockSlot)) internal lockTokenStorage;

    mapping (address => uint256[]) private lockSlotIdList;

    address[] internal holdersList;

    address[] internal totalSlot;

    uint256 public maximumDurationToFreeze;

    uint256 public lostTime;

    uint256 public totalLockedTokens;

    uint256[] _lockTokens;
     uint256[] _lockPeriods;
    function _createLockSlot()  {
        if (_lockPeriods.length > 1) {
            for(uint256 i = 1; i < _lockPeriods.length; i++) {
                _lockPeriods[i] += _lockPeriods[i+1];
            }
        }
    }
}