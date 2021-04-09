import sys
from slither.slither import Slither

def add_var(arg_map, var):
    type_name = str(var.type)
    if type_name in arg_map:
        arg_map[type_name].append(var.name)
    else:
        l = []
        l.append(var.name)
        arg_map[type_name] = l


if len(sys.argv) != 2:
    print('python main.py xxx.sol')
    exit(-1)


## Step 1: parse the original source .sol.
# Init slither
slither = Slither(sys.argv[1])

# Get the contract, all the contact's name is C by default.
contract = slither.get_contract_from_name('C')
harness_fun = contract.functions[0]
vars_map = {}

# Get the function, which has name 'foo' by default.
assert harness_fun.name == 'foo'

for var in harness_fun.variables_read:
    add_var(vars_map, var)

print(vars_map)

## Step 2: generate the target DSL.
print('working on the DSL')

