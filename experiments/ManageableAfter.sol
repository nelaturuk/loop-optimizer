contract Manageable {
    address[] public managers;

    function removeManager() public {
    uint initial = 0;
    uint mapstart = 0;
    uint mapend = 1;
    uint loopcondition = managers.length;
    removeManager_for(initial, loopcondition, mapstart, mapend);
  }
  function removeManager_for(uint initial, uint loopcondition, uint _mapstart, uint _mapend) internal {
  for (uint i = initial; i < loopcondition; ++i) {
          managers[i + _mapstart] = managers[i + _mapend];
    }
  }
}