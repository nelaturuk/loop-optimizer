from slither import Slither
from dependency import Dependency
from refinement import Refinement
from lambdaAnalysis import LambdaAnalysis

import argparse
import re

def setupArgs():
    parser = argparse.ArgumentParser(description='Run dependency and refinement analysis on solidity loops.')
    parser.add_argument('--f', type=str, dest='fname', required=True,
                        help='file with loop to be analyzed')
    parser.add_argument('--c', type=str, default='MyContract', dest='cname',
                        help='name of contract in file')
    parser.add_argument('--func', type=str, default='foo()', dest='funcname',
                        help='name of function in file')
    parser.add_argument('--print', default=False, action='store_true',
                        dest='print_output', help='name of function in file')

    args = parser.parse_args()    

    return args

def find_deps(deps, toVisit, visited):
    for v in toVisit:
        if not v in visited:
            visited.add(v)        
            if v in deps:
                visited = find_deps(deps, deps[v], visited)

    return visited

def transitive_close(deps):
    new_deps = {}
    changed = True
    while changed:
        changed = False
        for tgt,vdeps in deps.items():
            new_deps_tgt = find_deps(deps, vdeps, set())
            if not tgt in new_deps or new_deps_tgt != new_deps[tgt]:
                new_deps[tgt] = new_deps_tgt
                changed = True
            
    return new_deps

def analyze_lambdas(fname, cname='MyContract', funcname='foo()'):
    slither = Slither(fname)
    myContract = slither.get_contract_from_name(cname)

    return get_lambda_analysis(fname, myContract, slither)

def get_lambda_analysis(fname, myContract, slither):
    # Lambda Analysis
    L = LambdaAnalysis()
    L.exprs = []
    L.compute_contract(myContract, slither)

    return get_lambdas(L.exprs)

def get_lambdas(exprs):
    commutative_operators = ["+", "*", "&&", "||"]
    # keeps track of expressions which can be used as args to lambda operations
    #   where one side can be replaced
    vs = [] 
    lambdas = []
    lambda_vname = "__x"
    for expr in exprs:
        op = expr[0]
        arg1 = expr[1][0]
        arg2 = expr[1][1]
        if arg1[0] and arg2[0]:
            vs.append("{0}{1}{2}".format(arg1[1], op, arg2[1]))
        elif not arg1[0] and not arg2[0]:
            for v in vs:
                lambdas.append("lambda {0}: {1}{2}{0}".format(lambda_vname, v, op))
                if not op in commutative_operators:
                    lambdas.append("lambda {0}: {1}{2}{0}".format(v, lambda_vname, op))                
        else:
            if arg1[0]:
                new_vs = [] + vs
                for v in vs:
                    lambdas.append("lambda {3}: {0}{1}({2})".format(arg1[1], op, v, lambda_vname))
                for v in vs:
                    new_vs.append("{0}{1}({2})".format(arg1[1], op, v))
                vs = new_vs
                lam = "{0}{1}{2}".format(arg1[1], op, lambda_vname)
                if not lam in vs:
                    vs.append(lam)
                lambdas.append("lambda {0}: {1}{2}{0}".format(lambda_vname, arg1[1], op))
            else:
                new_vs = [] + vs
                for v in vs:
                    lambdas.append("lambda {3}: ({0}){1}{2}".format(v, op, arg2[1], lambda_vname))
                for v in vs:
                    new_vs.append("({0}){1}{2}".format(v, op, arg2[1]))
                vs = new_vs
                lam = "{0}{1}{2}".format(lambda_vname, op, arg2[1])
                if not lam in vs:
                    vs.append(lam)
                lambdas.append("lambda {0}: {0}{2}{1}".format(lambda_vname, arg2[1], op))

    return lambdas

def get_requires_conditions(fname):
    # TODO: replace with slithir AST traversing
    conds = []
    if fname != '':
        with open(fname, 'r') as sol_file:
            # Find requires statements
            req = r'require\s*\((.*)\);'
            match = re.search(req, sol_file.read())
            if match:                
                conds.append(match.group(1))

    return conds
                
def analyze(fname, cname='MyContract', funcname='foo()'):
    slither = Slither(fname)

    myContract = slither.get_contract_from_name(cname)
    funcA = myContract.get_function_from_signature(funcname)
    
    # Dependency Analysis
    D = Dependency()
    D.compute_contract(myContract, slither)
    D.dependencies = funcA.context[D.KEY_NON_SSA]
    
    # Refinement Analysis
    R = Refinement()
    R.compute_contract(myContract, slither, fname)

    # Lambda Analysis
    lambdas = get_lambda_analysis(fname, myContract, slither)

    # For Guard Types, use Dependency Analysis to fetch all vars which affect
    #   the Guard (i.e. on which the guard depends)
    guards = []
    for var in R.types[R.Typ.GUARD]:
        if var in D.dependencies:
            guards += D.dependencies[var]
    R.types[R.Typ.GUARD] += guards

    # Remove temporary variables and ref vars from types
    to_delete = {}
    for typ in R.types:
        to_delete[typ] = []
        if typ != 6 and typ != 7:
            for var in R.types[typ]:
                if var.name.startswith("REF") or var.name.startswith("TMP"):
                    to_delete[typ].append(var)

    for k,vals in to_delete.items():
        for v in vals:
            R.types[k].remove(v)
                
    # Remove temporary variables and ref vars from dependencies
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

    # Fetch written and read types from dependencies
    R.types[R.Typ.WRITTEN] += D.dependencies.keys()
    R.types[R.Typ.READ] += [x for vals in D.dependencies.values() for x in vals]

    # Anything that is an index or guard is also read
    R.types[R.Typ.READ] += R.types[R.Typ.INDEX]
    R.types[R.Typ.READ] += R.types[R.Typ.GUARD]
    R.types[R.Typ.READ] += R.types[R.Typ.GUARDSTART]
    R.types[R.Typ.READ] += R.types[R.Typ.GUARDEND]
        
    # Reformat refinement type entries
    R_types_formatted = {}
    for typ, vrs in R.types.items():
        # Special check for lower casing True and False constants
        rhs = set(map(lambda v: v.lower() if v=="True" or v=="False" else v,
                       set(map(str, vrs))))
        typ = typ.lower() if typ == "True" or typ == "False" else typ
        R_types_formatted[typ] = rhs
    R.types = R_types_formatted

    # Reformat dependencies entries
    dependencies_formatted = {}
    for v, vrs in D.dependencies.items():
        # Special check for lower casing True and False constants
        lhs = str(v).lower() if str(v) == "True" or str(v) == "False" else str(v)
        rhs = set(map(lambda v: v.lower() if v=="True" or v=="False" else v,
                       set(map(str, vrs))))
        dependencies_formatted[lhs] = rhs
    D.dependencies = dependencies_formatted
    
    # Add lambdas to dependencies based on sub-parts
    dependencies_lambdas = {}
    for v, vrs in D.dependencies.items():
        dependencies_lambdas[v] = vrs
        for lam in lambdas:
            lam_vrs = re.findall(r"[\w']+", lam[lam.index(":")+1:])
            if any(map(lambda lv: lv in vrs, lam_vrs)):
                dependencies_lambdas[v].add(lam)
    D.dependencies = dependencies_lambdas
    
    # # Transitive Closure of Dependencies
    # D.dependencies = transitive_close(D.dependencies)
        
    return D, R    

if __name__ == '__main__':
    args = setupArgs()
    D, R = analyze(args.fname, args.cname, args.funcname)
    L = analyze_lambdas(args.fname, args.cname, args.funcname)
    if args.print_output:        
        D.pprint_dependency()
        R.pprint_refinement()
        print("Lambdas: {0}".format(L))
