contract Manageable {
    address[] public managers;

    function removeManager() public {
        for(uint i = 0; i < managers.length - 1; i++) {
            managers[i] = managers[i + 1];
        }
    }
}