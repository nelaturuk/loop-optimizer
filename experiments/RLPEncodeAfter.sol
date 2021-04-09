contract RLPEncode {
    uint8 constant STRING_SHORT_PREFIX = 0x80;
    uint8 constant STRING_LONG_PREFIX = 0xb7;
    uint8 constant LIST_SHORT_PREFIX = 0xc0;
    uint8 constant LIST_LONG_PREFIX = 0xf7;
    bytes strBytes;
    bytes result;
    uint startIndex;
    uint endIndex;
    function wrapNFTs() public {
    uint initial = startIndex;
    uint mapstart = startIndex;
    uint mapend = 0;
    uint loopcondition = endIndex;
    wrapNFTs_for(initial, loopcondition, mapstart, mapend);
  }
  function wrapNFTs_for(uint initial, uint loopcondition, uint _mapstart, uint _mapend) internal {
  for (uint i = initial; i < loopcondition; ++i) {
          result[i + _mapstart] = strBytes[i + _mapend];
    }
  }
}