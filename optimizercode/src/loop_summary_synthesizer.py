#!/usr/bin/env python

from sys import argv
import tyrell.spec as S
from tyrell.interpreter import PostOrderInterpreter
from tyrell.enumerator import HoudiniEnumerator
from tyrell.decider import Example, BoundedModelCheckerDecider
from tyrell.synthesizer import Synthesizer
from tyrell.logger import get_logger
from slither.slither import Slither
from verify import check_eq

import sys
sys.path.append("../analysis")

from analyze import analyze, analyze_lambdas
from itertools import combinations, product 
import re
from collections import defaultdict

logger = get_logger('tyrell')

def add_var(arg_map, var):
    type_name = str(var.type)
    if type_name in arg_map:
        if not var.name in arg_map[type_name]:
            arg_map[type_name].append(var.name)
    else:
        l = []
        l.append(var.name)
        arg_map[type_name] = l

def fetch_iterators(sol_file):
    with open(sol_file, "r") as f:
        ind = "//#LOOPVARS: "
        body = f.read()
        if ind in body:
            # Parse syntax arround global variables
            iterator_vars = body[body.index(ind)+12:].split("\n")[0]
            iterator_vars = iterator_vars.replace('[', "").replace(']', "").replace("'", "").replace(" ", "").split(", ")
        else:
            # If analysis reported no loop variables, assume iterator is "i" and global
            iterator_vars = ["i"]

    return iterator_vars

def build_glob_decl(vars_map, iterator_var, i_global):
    glob_decl = ""
    for k,vs in vars_map.items():
        glob_decl += "".join(map(lambda v: "" if (v == iterator_var and not i_global)
                                 else k + ' ' + v + '; \n', vs)) 

    return glob_decl

def build_type_table(vars_map, all_types, map_types):
    type_table = defaultdict(list)
    
    # Iterate through all global variables
    for typ in vars_map:
        # Add quotes to each variable of type "typ"
        q_vars = map(lambda v: '"' + v + '"', vars_map[typ]) 
        q_vars_list = ",".join(list(q_vars))

        # If type is an array, add its length to integers, and then
        #   convert the type to the appropriate mapping
        if "[]" in typ:
            len_vars = list(map(lambda v: '"{0}.length"'.format(v), vars_map[typ]))
            type_table["uint"] += len_vars
            k = "mapping(uint => {0})".format(typ.replace("[]", ""))

        # Replace different bit amount variables with base version
        type_replacements = {"uint": ["uint8", "uint128", "uint256"],
                             "bytes": ["bytes32"]}
        for repl,orig_typs in type_replacements.items():
            for o_typ in orig_typs:
                typ = typ.replace(o_typ, repl)

        # Only add known types to type table
        if typ in all_types:
            # Convert map types syntax for DSL language
            if typ in map_types:
                matches = re.findall(r"(mapping\((.*) => (.*)\))", typ)
                if matches != []:
                    dom = matches[0][1]
                    codom = matches[0][2]
                    typ = "mapping_{0}_{1}".format(dom, codom)

            # add values of type "k" to the table
            type_table[typ] += q_vars_list.split(",")
        else:
            print("IGNORED TYPE: {0}!".format(typ))

    return type_table

def instantiate_dsl(sol_file):
    # Init slither
    slither = Slither(sol_file)

    # Get the contract, all the contact's name is C by default.
    contract = slither.get_contract_from_name('C')
    other_contracts = list(filter(lambda x: x != 'C', map(str, slither.contracts)))
    harness_fun = contract.functions[0]
    vars_map = {}

    # Get the function, which has name 'foo' by default.
    assert harness_fun.name == 'foo'

    # Add all read and written variables to the variable map
    for var in harness_fun.variables_read:
        add_var(vars_map, var)

    for var in harness_fun.variables_written:
        add_var(vars_map, var)

    actual_spec = dsl_skeleton
    
    int_str = ""
    address_str = ""
    maparray_str = ""
    mapint_str = ""

    # Fetch the variable used as the loop iterator
    # TODO: Handle multiple iterators (i.e. multiple loops)?    
    iterator_var = fetch_iterators(sol_file)[0]
    
    # Check if "i", the iterator we use to translate dsl, is a global variable
    i_global = iterator_var in list(map(str, contract.variables))    

    # Build global variable declarations for produced dsl solidity code
    glob_decl = build_glob_decl(vars_map, iterator_var, i_global)

    # List of basic solidity types, plus any user defined types (other_contracts)
    base_types = ["uint", "bool", "address", "bytes"] + other_contracts

    # Construct all possible (non-nested) map types using the base types
    map_types = list(map(lambda x: "mapping({0} => {1})".format(x[0], x[1]), product(base_types, repeat=2)))

    # List all types, including the special "g_int", which is used for global integers
    all_types = base_types + map_types + ["g_int"]

    # Maps types to global variables of that type
    type_table = build_type_table(vars_map, all_types, map_types)

    # Copy global integers into special separate type "g_int"
    type_table["g_int"] = list(set(type_table["uint"]))

    # Constant values
    # TODO: Use analysis to get these!
    # C = ['"0"', '"1"', '"-1"']
    C = ['"0"', '"1"']

    # Add int constants separately for DSL where only constants are needed
    type_table["C"] = C
    # Non-zero values for div and mul
    type_table["nonzero_uint"] = list(set(type_table["uint"] + [C[1]]))
    # Add int constants to ints
    type_table["uint"] = list(set(type_table["uint"]+C))
    # Add "true" and "false" as boolean constants
    type_table["bool"] = list(set(type_table["bool"]+['"true"', '"false"']))    

    
    # Build DSL enums from type table
    typ_enums = ""
    for typ, vals in type_table.items():
        typ_enums +="""
        enum {0} {{
            {1}
        }}
        """.format(typ, ",".join(vals))

    # Uses the type_table to expand wild cards from DSL
    actual_spec = expand_dsl(actual_spec, type_table, base_types, all_types)    

    # Fills in typ_enums
    actual_spec = actual_spec.format(types=typ_enums)
    
    return actual_spec, glob_decl, i_global, [iterator_var]

def convert_map_types(types):
    new_types = set()
    for typ in types:
        matches = re.findall(r"(mapping\((.*) => (.*)\))", typ)
        if matches != []:
            full_dec = matches[0][0]
            dom = matches[0][1]
            codom = matches[0][2]
            new_type = "mapping_{0}_{1}".format(dom, codom)
            new_types.add(new_type)
        else:
            new_types.add(typ)

    return list(new_types)

def replace_map_types_and_fetch_map_wildcards(line):
    map_wildcards = set()
    args = line.replace(";","").split("->")[1].split(",")
    for arg in args:
        matches = re.findall(r"(mapping\((.*) => (.*)\))", arg)
        if matches != []:
            full_dec = matches[0][0]
            dom = matches[0][1]
            codom = matches[0][2]
            new_type = "mapping_{0}_{1}".format(dom, codom)
            line = line.replace(full_dec, new_type)
            if dom.startswith("#"): map_wildcards.add(dom)
            if codom.startswith("#"): map_wildcards.add(codom)

    return line, map_wildcards

def find_non_map_wildcards(line, map_wildcards):
    matches = re.findall(r"(__(.*):)", line)
    wildcards = set()
    if matches != []:
        wildcards = set(matches[0][1].split("_"))
        wildcards -= map_wildcards

    return wildcards

def expand_wildcards(wildcards, types, lines):
    new_lines = []
    if len(wildcards) > 0:
        poss_types = product(types, repeat=len(wildcards))
        for types in poss_types:
            for new_line in lines:
                for wildcard,typ in zip(wildcards, list(types)):
                    new_line = new_line.replace(wildcard, typ)
                new_lines.append(new_line)
    else:
        for new_line in lines:
            new_lines.append(new_line)

    return new_lines
                
def remove_impossible_types(dsl, type_table, final_funcs):    
    added_type = False
    for line in dsl:
        line_split = line.replace(";","").replace(" ", "").split("->")
        args = line_split[1].split(",")
        ret_type = line_split[0].split(":")[1].replace(" ", "")

        # if all types are in the type table and the line has not already been added
        if (all(map(lambda a: a in type_table and (len(type_table[a]) > 0), args)) and
            (not line in final_funcs)):
            final_funcs.append(line)
            if not ret_type in type_table: type_table[ret_type] = ["42"]
            added_type = True
    
    if added_type:
        return remove_impossible_types(dsl, type_table, final_funcs)

    return final_funcs
    
def expand_dsl(dsl, type_table, base_types, all_types):
    all_types = convert_map_types(all_types)
    function_lines = []
    other_lines = []
    for line in dsl.split("\n"):
        if line.startswith("func"):
            # Fetch wildcards which appear in map, and replace map syntax
            line, map_wildcards = replace_map_types_and_fetch_map_wildcards(line)

            # Fetch wildcards which do not appear in map
            wildcards = find_non_map_wildcards(line, map_wildcards)
            
            # Duplicate line for all possible wildcard values, which include map types
            wildcard_lines = expand_wildcards(wildcards, all_types, [line])
            
            # Duplicate all wildcard lines by expanding map wildcards, which cannot be map
            #    types due to restriction on no nested mappings
            map_wildcard_lines = expand_wildcards(map_wildcards, base_types, wildcard_lines)

            # Write all duplicated lines
            for new_line in map_wildcard_lines:
                function_lines.append(new_line)
        else:
            # Write all non-func lines
            other_lines.append(line)

    # Remove types which could never be created (due to the types of globals)
    function_lines = remove_impossible_types(function_lines, type_table, [])

    return "\n".join(other_lines + function_lines)

min_dsl = '''

{types}

value L;
value IF;
value i;
value F;
value Cond;
value Inv;

program SolidityLoops() -> Inv;

# DSL Functions (with lambda versions when appropriate)
func SUM: IF -> g_int, mapping(uint => uint), i, i;

func seq: Inv -> Inv, Inv;

func intFunc: Inv -> IF;

# Add constant for global integers
func addc: i -> g_int, C;
'''

dsl_skeleton ='''
{types}

value L;
value IF;
value i;
value F;
value Cond;
value Summary;
value Inv;

program SolidityLoops() -> Summary;

func summarize: Summary -> Inv;

func seqF: Inv -> F, Inv;
func seqIF: Inv -> IF, Inv;

func intFunc: Inv -> IF;
func nonintFunc: Inv -> F;

# DSL Functions (with lambda versions when appropriate)
func SUM_L: IF -> g_int, mapping(uint => uint), i, i, L;
func SUM: IF -> g_int, mapping(uint => uint), i, i;
func COPYRANGE_L: IF -> mapping(uint => uint), i, mapping(uint => uint), i, i, L;
func COPYRANGE__#A: IF -> mapping(uint => #A), i, mapping(uint => #A), i, i;
func UPDATERANGE__#A_#B: F -> mapping(uint => #A), mapping(#A => #B), i, i, #B;
func MAP_L: IF -> mapping(uint => uint), i, i, L;
func MAP__#A: F -> mapping(uint => #A), i, i, #A;
func INCRANGE_L: IF -> mapping(uint => uint), i, mapping(uint => uint), i, i, L;
func INCRANGE: IF -> mapping(uint => uint), i, mapping(uint => uint), i, i;
func FILTER__#A: F -> mapping(uint => #A), IF, Cond;

# Arithmetic funcs for lambda
func add: L -> uint;
func mul: L -> nonzero_uint;
func sub: L -> uint;
func div: L -> nonzero_uint;

# Add constant for global integers
func addc: i -> g_int, C;

# Boolean funcs for conditional lambda
func lt: Cond -> uint;
func gt: Cond -> uint;
func eq: Cond -> uint;
func lte: Cond -> uint;
func gte: Cond -> uint;
func and: Cond -> Cond, Cond;
func or: Cond -> Cond, Cond;
'''

dsl_backup='''
{types}

value L;
value IF;
value i;
value F;
value Cond;
value Summary;
value Inv;

program SolidityLoops() -> Summary;

func summarize: Summary -> Inv;

func seq: Inv -> Inv, Inv;

func intFunc: Inv -> IF;
func nonintFunc: Inv -> F;

# DSL Functions (with lambda versions when appropriate)
func SUM_L: IF -> g_int, mapping(uint => uint), i, i, L;
func SUM: IF -> g_int, mapping(uint => uint), i, i;
func COPYRANGE_L: IF -> mapping(uint => uint), i, mapping(uint => uint), i, i, L;
func COPYRANGE__#A: IF -> mapping(uint => #A), i, mapping(uint => #A), i, i;
func UPDATERANGE__#A_#B: F -> mapping(uint => #A), mapping(#A => #B), i, i, #B;
func MAP_L: IF -> mapping(uint => uint), i, i, L;
func MAP__#A: F -> mapping(uint => #A), i, i, #A;
func INCRANGE_L: IF -> mapping(uint => uint), i, mapping(uint => uint), i, i, L;
func INCRANGE: IF -> mapping(uint => uint), i, mapping(uint => uint), i, i;
func FILTER__#A: F -> mapping(uint => #A), IF, Cond;

# Arithmetic funcs for lambda
func add: L -> uint;
func mul: L -> uint;
func sub: L -> uint;
func div: L -> uint;
func const__#A: L -> #A;

# Add constant for global integers
func addc: i -> g_int, C;

# Boolean funcs for conditional lambda
func lt: Cond -> uint;
func gt: Cond -> uint;
func eq: Cond -> uint;
func lte: Cond -> uint;
func gte: Cond -> uint;
func and: Cond -> Cond, Cond;
func or: Cond -> Cond, Cond;
'''

class SymDiffInterpreter(PostOrderInterpreter):

    program_decl = ""

    contract_prog = """pragma solidity ^0.5.10;

        contract C {{
            
            {_decl}

            function foo() public {{

                {_body}

            }}
        }}"""

    extra_contract = """
    contract {0} {{{{ }}}}
    """

    def __init__(self, decl="", contracts=[], i_global=False, global_vars=["i"]):
        for contract in contracts:
            self.contract_prog += self.extra_contract.format(contract)
        self.program_decl = decl
        self.i_typ = "" if i_global else "uint"
        # TODO: HANDLE NESTED LOOPS
        self.iterator = global_vars[0]

    #########################################
    # Conditional Operators
    #########################################
        
    def eval_lt(self, node, args):
        return "__y" + "<" + args[0]

    def eval_lte(self, node, args):
        return "__y" + "<=" + args[0]

    def eval_eq(self, node, args):
        return "__y" + "==" + args[0]
    
    def eval_gt(self, node, args):
        return "__y" + ">" + args[0]
    
    def eval_gte(self, node, args):
        return "__y" + ">=" + args[0]
    
    def eval_and(self, node, args):
        return args[0] + " && " + args[1]
    
    def eval_or(self, node, args):
        return args[0] + " || " + args[1]
    
    def eval_addc(self, node, args):
        # return "__x" + '+' + args[0]
        if args[1] == "-1":
            return args[0] + '-1'
        return args[0] + '+' + args[1]

    #########################################
    # Lambda operators
    #########################################

    def eval_const(self, node, args):
        return args[0]

    def eval_add(self, node, args):
        # return "__x" + '+' + args[0]
        if args[0] == "-1":
            return "__x-1"
        return "__x" + '+' + args[0]

    def eval_sub(self, node, args):
        return "__x" + '-' + args[0]

    def eval_mul(self, node, args):
        return "__x" + '*' + args[0]
    
    def eval_div(self, node, args):
        return "__x" + '/' + args[0]

    #########################################
    # DSL
    #########################################
    def build_sum(self, node, args, l):
        acc = args[0]
        arr = args[1]
        start_idx = args[2]
        end_idx = args[3]

        val = "{srcArr}[{it}]".format(srcArr=arr, it=self.iterator)
        
        if l == False:
            lam = "+= {0}".format(val)
        else:
            lam = args[4]
            if lam == "-1":
                lam = "-= 1"
            else:
                lam = "+= "+lam
            lam = lam.replace("__x", val)
        
        loop_body = """
            for ({i_typ} {it} = {tgtStart}; {it} < {tgtEnd}; ++{it}) {{
                {tgtAcc} {lamVal};
            }}
        """.format(tgtStart=start_idx, tgtEnd=end_idx, tgtAcc=acc, lamVal=lam, i_typ=self.i_typ, it=self.iterator)

        return loop_body, val
        
    def eval_SUM(self, node, args):
        return self.build_sum(node, args, False)

    def eval_SUM_L(self, node, args):
        return self.build_sum(node, args, True)
    
    def build_copyrange(self, node, args, l):        
        src_array = args[0]
        start_src = args[1]
        tgt_array = args[2]
        start_tgt = args[3]
        end_tgt = args[4]

        val = "{srcObj}[{it}+{srcStart}-{tgtStart}]".format(srcObj=src_array,
                                                            it=self.iterator,
                                                            srcStart=start_src,
                                                            tgtStart=start_tgt)        
        if l == False:
            lam = val
        else:
            lam = args[5]
            lam = lam.replace("__x", val)
            
        loop_body = """
            for ({i_typ} {it} = {tgtStart}; {it} < {tgtEnd}; {it}++) {{
                {tgtObj}[{it}] = {lamVal};
            }}
        """.format(tgtStart=start_tgt, tgtEnd=end_tgt, tgtObj=tgt_array,
                   i_typ=self.i_typ, it=self.iterator, lamVal=lam)

        return loop_body, val
    
    def eval_COPYRANGE(self, node, args):
        return self.build_copyrange(node, args, False)

    def eval_COPYRANGE_L(self, node, args):
        return self.build_copyrange(node, args, True)

    def build_shiftleft(self, node, args, l):        
        src_array = args[0]
        start_idx = args[1]
        end_idx = args[2]

        val = "{arr}[{it}+1]".format(arr=src_array, it=self.iterator)

        if l == False:
            lam = val
        else:
            lam = args[3]
            lam = lam.replace("__x", val)

        
        loop_body = """
            for ({i_typ} {it} = {start}; {it} < {end}; {it}++) {{
                {arr}[{it}] = {lamVal};
            }}
        """.format(start=start_idx, end=end_idx, arr=src_array,
                   i_typ=self.i_typ, it=self.iterator, lamVal=lam)

        return loop_body, val

    def eval_SHIFTLEFT(self, node, args):
        return self.build_shiftleft(node, args, False)

    def eval_SHIFTLEFT_L(self, node, args):
        return self.build_shiftleft(node, args, True)

    def build_updaterange(self, node, args, l):        
        cont = args[0]
        tgt = args[1]
        start = args[2]
        end = args[3]
        val = args[4]

        if l == False:
            lam = val
        else:
            lam = args[5]
            lam = lam.replace("__x", val)

        loop_body = """
            for ({i_typ} {it} = {startIdx}; {it} < {endIdx}; {it}++) {{
                {tgtArr}[{contArr}[{it}]] = {lamVal};
            }}
        """.format(tgtArr=tgt, contArr=cont, startIdx=start, endIdx=end, lamVal=lam, i_typ=self.i_typ, it=self.iterator)

        return loop_body, "{tgtArr}[{contArr}[{it}]]".format(tgtArr=tgt, contArr=cont,
                                                             it=self.iterator)

    def eval_UPDATERANGE(self, node, args):
        return self.build_updaterange(node, args, False)

    def eval_UPDATERANGE_L(self, node, args):
        return self.build_updaterange(node, args, True)

    def build_map(self, node, args, l):        
        tgt = args[0]
        start = args[1]
        end = args[2]        
        lam = args[3]

        val = "{tgtArr}[{it}]".format(tgtArr=tgt, it=self.iterator)
        
        if l:
            lam = lam.replace("__x", val)

        loop_body = """
            for ({i_typ} {it} = {start_idx}; {it} < {end_idx}; {it}++) {{
                {tgtArr}[{it}] = {lamVal};
            }}
        """.format(tgtArr=tgt, start_idx=start, end_idx=end,
                   lamVal=lam, i_typ=self.i_typ, it=self.iterator)

        return loop_body, val

    def eval_MAP(self, node, args):
        return self.build_map(node, args, False)

    def eval_MAP_L(self, node, args):
        return self.build_map(node, args, True)

    def build_incrange(self, node, args, l):        
        src = args[0]
        start_src = args[1]
        tgt = args[2]
        start_tgt = args[3]
        end_tgt = args[4]        

        val = "{srcArr}[{it}+{srcStart}-{tgtStart}]".format(srcArr=src, it=self.iterator,
                                                            srcStart=start_src,
                                                            tgtStart=start_tgt)
        
        if not l:
            lam = val
        else:
            lam = args[5]
            lam = lam.replace("__x", val)
            
        loop_body = """
            for ({i_typ} {it} = {tgtStart}; {it} < {tgtEnd}; {it}++) {{
                {tgtArr}[{it}] += {lamVal};
            }}
        """.format(tgtArr=tgt, tgtStart=start_tgt, tgtEnd=end_tgt, srcArr=src,
                   srcStart=start_src, i_typ=self.i_typ, it=self.iterator, lamVal=lam)

        return loop_body, val

    def eval_INCRANGE(self, node, args):
        return self.build_incrange(node, args, False)

    def eval_INCRANGE_L(self, node, args):
        return self.build_incrange(node, args, True)

    def eval_FILTER(self, node, args):
        tgt = args[0]        
        loop, cond_arg = args[1]
        cond = args[2].replace("__y", cond_arg)

        matches = re.findall(r"(.*)\{.*\n(.*)\n.*\}", loop)
        if matches != []:
            header = matches[0][0].replace(" ", "")
            body = matches[0][1].replace(" ", "")
            new_loop = """
            {header} {{
                if ({cond}) {{
                    {body}
                }}
            }}
            """.format(header=header, body=body, cond=cond)
        else:
            raise Exception("No body in:\n {0}".format(loop))

        return new_loop, None 
        
    def eval_summarize(self, node, args):
        body, _ = args[0]
        actual_contract = self.contract_prog.format(_body=body, _decl=self.program_decl)

        print(actual_contract)
        return actual_contract

    def eval_intFunc(self, node, args):
        loop, _ = args[0]
        return loop, None

    def eval_nonintFunc(self, node, args):
        loop, _ = args[0]
        return loop, None

    def build_seq(self, node, args):
        loop0, _ = args[0]
        loop1, _ = args[1]        
        return loop0 + "\n\n" + loop1, None;

    def eval_seqF(self, node, args):
        return self.build_seq(node, args)

    def eval_seqIF(self, node, args):
        return self.build_seq(node, args)
    
def execute(interpreter, prog, args):
    return interpreter.eval(prog, args)


def test_all(interpreter, prog, inputs, outputs):
    return all(
        execute(interpreter, prog, inputs[x]) == outputs[x]
        for x in range(0, len(inputs))
    )


def main(sol_file):    
    seed = None
    # assert False

    # logger.info('Analyzing Input...')
    # deps, refs = analyze(sol_file, "C", "foo()")
    # lambdas = analyze_lambdas(sol_file, "C", "foo()")
    # logger.info('Analysis Successful!')

    # print(deps.dependencies)
    # print(refs.pprint_refinement())
    
    actual_spec, glob_decl, i_global, global_vars = instantiate_dsl(sol_file)

    print(actual_spec)
    
    logger.info('Parsing Spec...')
    spec = S.parse(actual_spec)
    logger.info('Parsing succeeded')

    # Fetch other contract names
    slither = Slither(sol_file)
    other_contracts = list(filter(lambda x: x != 'C', map(str, slither.contracts)))
    
    logger.info('Building synthesizer...')
    synthesizer = Synthesizer(
        enumerator=HoudiniEnumerator(
            spec, max_depth=10, seed=seed),
        decider=BoundedModelCheckerDecider(
            interpreter=SymDiffInterpreter(glob_decl, other_contracts, i_global, global_vars), example=sol_file, equal_output=check_eq)
    )
    logger.info('Synthesizing programs...')

    prog = synthesizer.synthesize()
    if prog is not None:
        logger.info('Solution found: {}'.format(prog))
        return True
    else:
        logger.info('Solution not found!')
        return False


if __name__ == '__main__':
    logger.setLevel('DEBUG')
    assert len(argv) > 1
    main(argv[1])
