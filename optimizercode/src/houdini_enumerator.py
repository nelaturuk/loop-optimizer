#!/usr/bin/env python

from sys import argv
import tyrell.spec as S
from tyrell.interpreter import PostOrderInterpreter
from tyrell.enumerator import HoudiniEnumerator
from tyrell.decider import Example, SymdiffDecider
from tyrell.synthesizer import Synthesizer
from tyrell.logger import get_logger
from slither.slither import Slither
from verify import check_eq

import sys
sys.path.append("../analysis")

from analyze import analyze, analyze_lambdas
from itertools import combinations, product 
import re

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

def instantiate_dsl(sol_file):
## Step 1: parse the original source .sol.
# Init slither
    slither = Slither(sol_file)

# Get the contract, all the contact's name is C by default.
    contract = slither.get_contract_from_name('C')
    other_contracts = list(filter(lambda x: x != 'C', map(str, slither.contracts)))
    harness_fun = contract.functions[0]
    vars_map = {}

# Get the function, which has name 'foo' by default.
    assert harness_fun.name == 'foo'

    for var in harness_fun.variables_read:
        add_var(vars_map, var)

    for var in harness_fun.variables_written:
        add_var(vars_map, var)

    actual_spec = toy_spec_str
    
    int_str = ""
    address_str = ""
    maparray_str = ""
    mapint_str = ""
    prog_decl = ""

    with open(sol_file, "r") as f:
        ind = "//#LOOPVARS: "
        body = f.read()
        if ind in body:
            global_vars = body[body.index(ind)+12:].split("\n")[0]
            global_vars = global_vars.replace('[', "").replace(']', "").replace("'", "").replace(" ", "").split(", ")
        else:
            global_vars = ["i"]
    
    #TODO: HANDLE NESTED LOOPS
    i_global = global_vars[0] in list(map(str, contract.variables))
    
    for k in vars_map:
        for v in vars_map[k]:
            if v == global_vars[0]:
                if i_global:
                    prog_decl += k + ' ' + v + '; \n'
            else:
                prog_decl += k + ' ' + v + '; \n'

    base_types = ["uint", "bool", "address", "bytes"] + other_contracts
    map_types = list(map(lambda x: "mapping({0} => {1})".format(x[0], x[1]), product(base_types, repeat=2)))

    all_types = base_types + map_types

    type_table = {}
    
    length_vars = []
    for k in vars_map:
        v = map(lambda x: '"' + x + '"', vars_map[k]) 
        actual_symbols = ",".join(list(v))
        print('parsing key:', k, ",".join(list(v)))
        if "[]" in k:
            length_vars += vars_map[k]            
            k = "mapping(uint => {0})".format(k.replace("[]", ""))
        k = k.replace("uint8", "uint")
        k = k.replace("uint128", "uint")        
        k = k.replace("uint256", "uint")
        k = k.replace("bytes32", "bytes")
        if k in all_types:
            if k in map_types:
                matches = re.findall(r"(mapping\((.*) => (.*)\))", k)
                if matches != []:
                    full_dec = matches[0][0]
                    dom = matches[0][1]
                    codom = matches[0][2]
                    k = "mapping_{0}_{1}".format(dom, codom)

            if not k in type_table:
                type_table[k] = actual_symbols.split(",")
            else:
                type_table[k] += actual_symbols.split(",")
        else:
            print("IGNORED TYPE: {0}!".format(k))
            pass

    if "uint" in type_table:
        type_table["uint"] += list(map(lambda v: '"{0}.length"'.format(v), length_vars))
    else:
        type_table["uint"] = list(map(lambda v: '"{0}.length"'.format(v), length_vars))

    type_table["uint"] = list(set(type_table["uint"]+['"0"', '"1"']))
    if not "bool" in type_table:
        type_table["bool"] = []
    type_table["bool"] = list(set(type_table["bool"]+['"true"', '"false"']))    
        
    typ_enums = ""
    for typ, vals in type_table.items():
        typ_enums +="""
        enum {0} {{
            {1}
        }}
        """.format(typ, ",".join(vals))
        
    actual_spec = expand_dsl(actual_spec, type_table, base_types)
    
    actual_spec = actual_spec.format(types=typ_enums)

    print(actual_spec)
    
    return actual_spec, prog_decl, i_global, global_vars

def expand_dsl(dsl, type_table, base_types):
    new_dsl = []
    for line in dsl.split("\n"):
        if line.startswith("func"):
            args = line.replace(";","").split("->")[1].split(",")
            wildcards = set()
            for arg in args:
                matches = re.findall(r"(mapping\((.*) => (.*)\))", arg)
                if matches != []:
                    full_dec = matches[0][0]
                    dom = matches[0][1]
                    codom = matches[0][2]
                    new_type = "mapping_{0}_{1}".format(dom, codom)
                    line = line.replace(full_dec, new_type)
                    if dom.startswith("#"): wildcards.add(dom)
                    if codom.startswith("#"): wildcards.add(codom)
            if len(wildcards) > 0:
                poss_types = product(base_types, repeat=len(wildcards))
                for types in poss_types:
                    new_line = line
                    for wildcard,typ in zip(wildcards, list(types)):
                        new_line = new_line.replace(wildcard, typ)
                    new_dsl.append(new_line)
            else:
                new_dsl.append(line)
        else:
            new_dsl.append(line)

    print("\n".join(new_dsl))
            
    final_dsl = []
    for line in new_dsl:
        if line.startswith("func"):
            args = line.replace(";","").replace(" ", "").split("->")[1].split(",")
            if all(map(lambda a: a in type_table and (len(type_table[a]) > 0), args)):
               final_dsl.append(line)
        else:
            final_dsl.append(line)        
            
    return "\n".join(final_dsl)

toy_spec_str = '''

{types}

value Inst;
value Stmt;
value Empty;
value endInt;
value Array;

program SymDiff() -> Inst;

func SEQ: Inst -> Inst, Inst;
func FOO: Inst -> uint;
'''

extra = '''
func addressToArray: Array -> MapArray, address;
func addressToInt: endInt -> MapInt, address;
func MAPLAMBDA__#A: Inst -> Write__mapping(uint => #A), Read_GuardStart__uint, Read_GuardEnd__uint, Lambda;
func SUMLAMBDA: Inst -> Write__uint, Read__mapping(uint => uint), Read_GuardStart__uint, Read_GuardEnd__uint, Lambda;

func UPDATERANGE__#A_#B: Inst -> mapping(uint => #A), mapping(#A => #B), uint, uint, #B;
func INCRANGE: Inst -> mapping(uint => uint), uint, mapping(uint => uint), uint, uint;
func COPYRANGE__#A: Inst -> mapping(uint => #A), uint, mapping(uint => #A), uint, uint;
func SUM: Inst -> uint, mapping(uint => uint), uint, uint;
func SHIFTLEFT__#A: Inst -> mapping(uint => #A), uint, uint;
func MAP__#A: Inst -> mapping(uint => #A), uint, uint, #A;

value Lambda;
value BOp;

func LOP: Lambda -> BOp;
func ROP: Lambda ->

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

    def eval_const(self, node, args):
        return args[0]

    def eval_plus(self, node, args):
        return args[0] + '+' + args[1]

    def eval_minus(self, node, args):
        return args[0] + '-' + args[1]

    def eval_mult(self, node, args):
        return args[0] + '*' + args[1]
    
    def eval_addressToArray(self, node, args):
        return args[0] + '[' + args[1] + ']'

    def eval_addressToInt(self, node, args):
        return args[0] + '[' + args[1] + ']'

    def eval_FOO(self, node, args):
        loop_body = """
            for ({i_typ} i = 0; i < 10; i++) {{
            }}
        """.format(i_typ=self.i_typ)

        actual_contract = self.contract_prog.format(_body=loop_body, _decl=self.program_decl)

        return actual_contract
    
    def eval_SEQ(self, node, args):
        loop_body = """
            for ({i_typ} i = 0; i < 10; i++) {{
            }}
        """.format(i_typ=self.i_typ)

        actual_contract = self.contract_prog.format(_body=loop_body, _decl=self.program_decl)

        return actual_contract
    
    def eval_SUM(self, node, args):
        acc = args[0]
        arr = args[1]
        start_idx = args[2]
        end_idx = args[3]

        loop_body = """
            for ({i_typ} {it} = {tgtStart}; {it} < {tgtEnd}; ++{it}) {{
                {tgtAcc} += {srcArr}[{it}];
            }}
        """.format(tgtStart=start_idx, tgtEnd=end_idx, tgtAcc=acc, srcArr=arr, i_typ=self.i_typ, it=self.iterator)

        actual_contract = self.contract_prog.format(_body=loop_body, _decl=self.program_decl)

        # print(actual_contract)
        # assert False
        return actual_contract
    
    def eval_COPYRANGE(self, node, args):        
        src_array = args[0]
        start_src = args[1]
        tgt_array = args[2]
        start_tgt = args[3]
        end_tgt = args[4]

        # if (start_src == "0" and start_tgt == "0"):
        #     loop_offset = ""
        # else:
        #     loop_offset = "+{0}-{1}".format(start_src, start_tgt)
            
        loop_body = """
            for ({i_typ} {it} = {tgtStart}; {it} < {tgtEnd}; {it}++) {{
                {tgtObj}[{it}] = {srcObj}[{it}+{srcStart}-{tgtStart}];
            }}
        """.format(tgtStart=start_tgt, tgtEnd=end_tgt, tgtObj=tgt_array,
                   srcStart=start_src, srcObj=src_array, i_typ=self.i_typ, it=self.iterator)
        
        actual_contract = self.contract_prog.format(_body=loop_body, _decl=self.program_decl)

        # print(actual_contract)
        # assert False
        return actual_contract

    def eval_SHIFTLEFT(self, node, args):        
        src_array = args[0]
        start_idx = args[1]
        end_idx = args[2]

        loop_body = """
            for ({i_typ} {it} = {start}; {it} < {end}; {it}++) {{
                {arr}[{it}] = {arr}[{it}+1];
            }}
        """.format(start=start_idx, end=end_idx, arr=src_array, i_typ=self.i_typ, it=self.iterator)

        actual_contract = self.contract_prog.format(_body=loop_body, _decl=self.program_decl)

        # print(actual_contract)
        # assert False
        return actual_contract

    def eval_UPDATERANGE(self, node, args):        
        cont = args[0]
        tgt = args[1]
        start = args[2]
        end = args[3]
        val = args[4]

        loop_body = """
            for ({i_typ} {it} = {startIdx}; {it} < {endIdx}; {it}++) {{
                {tgtArr}[{contArr}[{it}]] = {newVal};
            }}
        """.format(tgtArr=tgt, contArr=cont, startIdx=start, endIdx=end, newVal=val, i_typ=self.i_typ, it=self.iterator)
        
        actual_contract = self.contract_prog.format(_body=loop_body, _decl=self.program_decl)        
        
        print(actual_contract)
        # assert False
        return actual_contract

    def eval_MAP(self, node, args):        
        tgt = args[0]
        start = args[1]
        end = args[2]        
        val = args[3]

        loop_body = """
            for ({i_typ} {it} = {start_idx}; {it} < {end_idx}; {it}++) {{
                {tgtArr}[{it}] = {newVal};
            }}
        """.format(tgtArr=tgt, start_idx=start, end_idx=end, newVal=val, i_typ=self.i_typ, it=self.iterator)
        
        actual_contract = self.contract_prog.format(_body=loop_body, _decl=self.program_decl)

        # print(actual_contract)
        # assert False
        return actual_contract

    def eval_INCRANGE(self, node, args):        
        src = args[0]
        start_src = args[1]
        tgt = args[2]
        start_tgt = args[3]
        end_tgt = args[4]        

        loop_body = """
            for ({i_typ} {it} = {tgtStart}; {it} < {tgtEnd}; {it}++) {{
                {tgtArr}[{it}] += {srcArr}[{it}+{srcStart}-{tgtStart}];
            }}
        """.format(tgtArr=tgt, tgtStart=start_tgt, tgtEnd=end_tgt,
                   srcArr=src, srcStart=start_src, i_typ=self.i_typ, it=self.iterator)

        actual_contract = self.contract_prog.format(_body=loop_body, _decl=self.program_decl)

        return actual_contract

    def eval_MAPLAMBDA(self, node, args):        
        tgt = args[0]
        start = args[1]
        end = args[2]        
        lam = args[3]

        lam = lam[lam.index(":")+2:].replace("__x", "{0}[{1}]".format(tgt, self.iterator))
        
        loop_body = """
            for ({i_typ} {it} = {start_idx}; {it} < {end_idx}; {it}++) {{
                {tgtArr}[{it}] = {newVal};
            }}
        """.format(tgtArr=tgt, start_idx=start, end_idx=end, newVal=lam, i_typ=self.i_typ, it=self.iterator)

        actual_contract = self.contract_prog.format(_body=loop_body, _decl=self.program_decl)

        # print(actual_contract)
        # assert False
        return actual_contract

    def eval_SUMLAMBDA(self, node, args):
        acc = args[0]
        arr = args[1]
        start_idx = args[2]
        end_idx = args[3]
        lam = args[4]

        lam = lam[lam.index(":")+2:].replace("__x", "{0}[{1}]".format(arr, self.iterator))
        
        loop_body = """
            for ({i_typ} {it} = {tgtStart}; {it} < {tgtEnd}; ++{it}) {{
                {tgtAcc} += {lamVal};
            }}
        """.format(tgtStart=start_idx, tgtEnd=end_idx, tgtAcc=acc, lamVal=lam, i_typ=self.i_typ, it=self.iterator)

        actual_contract = self.contract_prog.format(_body=loop_body, _decl=self.program_decl)

        # print(actual_contract)
        # assert False
        return actual_contract
    

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

    actual_spec, prog_decl, i_global, global_vars = instantiate_dsl(sol_file)

    # print(actual_spec)
    
    logger.info('Parsing Spec...')
    spec = S.parse(actual_spec)
    logger.info('Parsing succeeded')

    # Fetch other contract names
    slither = Slither(sol_file)
    other_contracts = list(filter(lambda x: x != 'C', map(str, slither.contracts)))
    
    logger.info('Building synthesizer...')
    synthesizer = Synthesizer(
        enumerator=HoudiniEnumerator(
            spec, max_depth=2, seed=seed),
        decider=SymdiffDecider(
            interpreter=SymDiffInterpreter(prog_decl, other_contracts, i_global, global_vars), example=sol_file, equal_output=check_eq)
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
