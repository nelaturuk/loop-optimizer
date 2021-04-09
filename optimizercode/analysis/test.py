from slither import Slither
# from analysis import is_dependent, pprint_dependency, compute_dependency_contract
from dependency import Dependency
from refinement import Refinement


slither = Slither('data_dependency_simple_example.sol')

myContract = slither.get_contract_from_name('MyContract')
funcA = myContract.get_function_from_signature('foo()')

a = myContract.get_state_variable_from_name('a')
b = myContract.get_state_variable_from_name('b')
c = myContract.get_state_variable_from_name('c')
d = myContract.get_state_variable_from_name('d')

D = Dependency()

D.compute_contract(myContract, slither)
D.dependencies = funcA.context[D.KEY_NON_SSA]        

R = Refinement()
R.compute_contract(myContract, slither)

guards = []
for var in R.types[R.Typ.GUARD]:
    if var in D.dependencies:
        guards += D.dependencies[var]

R.types[R.Typ.GUARD] += guards

for typ in R.types:
    for var in R.types[typ]:
        if var.name.startswith("REF") or var.name.startswith("TMP"):
            R.types[typ].remove(var)

to_delete = []
for var in D.dependencies:
    if var.name.startswith("REF") or var.name.startswith("TMP"):
        to_delete.append(var)
    else:
        to_delete2 = []
        for var2 in D.dependencies[var]:
            if var2.name.startswith("REF") or var2.name.startswith("TMP"):
                to_delete2.append(var2)
        for x in to_delete2: D.dependencies[var].remove(x)
        if len(D.dependencies[var]) == 0: to_delete.append(var)
        
for x in to_delete:
    D.dependencies.pop(x, None)

R.types[R.Typ.WRITTEN] = D.dependencies.keys()
R.types[R.Typ.READ] = [x for vals in D.dependencies.values() for x in vals]
    
R.pprint_refinement()
D.pprint_dependency(funcA)
