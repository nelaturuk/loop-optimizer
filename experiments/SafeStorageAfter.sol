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

    function _createLockSlot() public {
    uint initial = 0;
    uint mapstart = 0;
    uint mapend = 1;
    uint loopcondition = _lockPeriods.length;
    _createLockSlot_for(initial, loopcondition, mapstart, mapend);
  }
  function _createLockSlot_for(uint initial, uint loopcondition, uint _mapstart, uint _mapend) internal {
  for (uint i = initial; i < loopcondition; ++i) {
      if (loopcondition > 1) {
          _lockPeriods[i + _mapstart] = _lockPeriods[i + _mapend];
      }
    }
  }
}