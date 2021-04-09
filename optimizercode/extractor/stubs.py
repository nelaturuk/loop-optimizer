# ERC20 stubs
#  - I am removing safemath so that at some point in future, maybe we could synthesize
#  - I have decided to not do in-place replacement now, as that is hard. In future,
#    in-place is probably the best way to do it.

msgSender='''
function _msgSender() public returns (address) {
    return msg.sender;
}
'''

totalSupply_vars=["uint256 _totalSupply;"]
totalSupply='''
function totalSupply() public view returns (uint256) {
    return _totalSupply;
}
'''

balanceOf_vars=["mapping (address => uint256) _balances;"]
balanceOf='''
function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
}
'''

safeTransfer_vars = []
safeTransfer='''
function safeTransfer(address recipient, uint256 amount) public returns (bool) {
    return transfer(recipient, amount);
}
'''

_safeTransfer_vars = []
_safeTransfer='''
function _safeTransfer(address recipient, uint256 amount) public returns (bool) {
    return transfer(recipient, amount);
}
'''

transfer_vars = []
transfer='''
function transfer(address recipient, uint256 amount) public returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
}

'''

_transfer_vars = ["mapping (address => uint256) _balances;"]
_transfer='''
function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    _balances[sender] = _balances[sender] - amount;
    _balances[recipient] = _balances[recipient] + amount;
}
'''

allowance_vars = ["mapping (address => mapping (address => uint256)) _allowances;"]
allowance='''
function allowance(address owner, address spender) public view returns (uint256) {
    return _allowances[owner][spender];
}
'''

approve_vars = []
approve='''
function approve(address spender, uint256 amount) public  returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
}
'''

transferFrom_vars = ["mapping (address => mapping (address => uint256)) _allowances;"]
transferFrom='''
function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
    return true;
}
'''

_approve_vars = ["mapping (address => mapping (address => uint256)) _allowances;"]
_approve='''
function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
}
'''

erc20 = {
    "totalSupply": totalSupply,
    "balanceOf": balanceOf,
    "allowance": allowance,
    "transfer": transfer + _transfer + msgSender,
    "approve": approve + _approve,
    "transferFrom": transferFrom + _transfer + msgSender + _approve,
    "safeTransfer": safeTransfer + transfer + _transfer + msgSender,
    "_transfer": _transfer + msgSender,
    "_safeTransfer": _safeTransfer + transfer + _transfer + msgSender,
    "_approve": _approve,
    "_msgSender": msgSender
    }

erc20_vars = {
    "totalSupply": totalSupply_vars,
    "balanceOf": balanceOf_vars,
    "allowance": allowance_vars,
    "transfer": list(set(transfer_vars + _transfer_vars)),
    "approve": list(set(approve_vars + _approve_vars)),
    "transferFrom": list(set(transferFrom_vars + _transfer_vars + _approve_vars)),
    "safeTransfer": list(set(safeTransfer_vars + transfer_vars + _transfer_vars)),
    "_transfer": _transfer_vars,
    "_safeTransfer": list(set(safeTransfer_vars + transfer_vars + _transfer_vars)),
    "_approve": _approve_vars,
    "_msgSender": []
    }

# SafeMath stubs
#  - from open zeppelin SafeMath.sol
#  - I remove requires, so that I can just synthesize non-safemath version

safe_add='''
function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;

    return c;
}
'''

safe_sub='''
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
}
'''

safe_sub_msg='''
function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    uint256 c = a - b;

    return c;
}
'''

safe_mul='''
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;

    return c;
}
'''

safe_div='''
function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
}
'''

safe_div_msg='''
function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    uint256 c = a / b;

    return c;
}
'''

safe_mod='''
function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
}
'''

safe_mod_msg='''
function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    return a % b;
}
'''

safemath = {
    "add": safe_add,
    "sub": safe_sub + safe_sub_msg,
    "mul": safe_mul,
    "div": safe_div + safe_div_msg,
    "mod": safe_mod + safe_mod_msg
    }
