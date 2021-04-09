#!/usr/bin/env python

from sys import argv
import tyrell.spec as S
from tyrell.interpreter import PostOrderInterpreter
from tyrell.enumerator import RandomEnumerator
from tyrell.decider import Example, SymdiffDecider
from tyrell.synthesizer import Synthesizer
from tyrell.logger import get_logger
from slither.slither import Slither
from verify import check_eq

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

    for k in vars_map:
        for v in vars_map[k]:
            prog_decl += k + ' ' + v + '; \n'

    for k in vars_map:
        v = map(lambda x: '"' + x + '"', vars_map[k]) 
        actual_symbols = ",".join(list(v))
        print('parsing key:', k, ",".join(list(v)))
        if k == 'uint256':
            int_str = actual_symbols
        elif k == 'address':
            address_str = actual_symbols
        elif k == 'mapping(address => uint256)':
            mapint_str = actual_symbols
        elif k == 'mapping(address => uint256[])':
            maparray_str = actual_symbols
        else:
            pass
    
    actual_spec = actual_spec.format(startInt=int_str,Address=address_str, 
                                    MapInt=mapint_str, MapArray=maparray_str)
    return actual_spec, prog_decl

#COPYRANGE(lockTime[_address], i0, lockNum[_address], tempLockTime, i0, lockNum[address], λ arg: arg+later-earlier)
# for (uint i = 0; i < lockNum[_address]; ++i) {
#   tempLockTime[_address][i] = lockTime[_address][i] + later-earlier;
# }  

toy_spec_str = '''
enum startInt {{
  "0"
}}

enum address {{
    {Address}
}}

enum MapArray {{
    {MapArray}
}}

enum MapInt {{
    {MapInt}
}}

value Inst;
value Stmt;
value Empty;
value endInt;
value Array;

program SymDiff(Stmt) -> Inst;
func addressToArray: Array -> MapArray, address;
func addressToInt: endInt -> MapInt, address;
func COPYRANGE: Inst -> Array, startInt, endInt, Array, startInt, endInt;
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

    def __init__(self, decl=""):
        self.program_decl = decl

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

    def eval_COPYRANGE(self, node, args):
        
        src_array = args[0]
        start_idx = args[1]
        end_idx = args[2]
        tgt_array = args[3]

        loop_body = """
            for (uint i = {tgtStart}; i < {tgtEnd}; ++i) {{
                {tgtObj}[i] = {srcObj}[i];
            }}
        """.format(tgtStart=start_idx, tgtEnd=end_idx, tgtObj=tgt_array, srcObj=src_array)

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
    actual_spec, prog_decl = instantiate_dsl(sol_file)
    print(actual_spec)
    # assert False
    logger.info('Parsing Spec...')
    spec = S.parse(actual_spec)
    logger.info('Parsing succeeded')

    logger.info('Building synthesizer...')
    synthesizer = Synthesizer(
        enumerator=RandomEnumerator(
            spec, max_depth=4, seed=seed),
        decider=SymdiffDecider(
            interpreter=SymDiffInterpreter(prog_decl), example=sol_file, equal_output=check_eq)
    )
    logger.info('Synthesizing programs...')

    prog = synthesizer.synthesize()
    if prog is not None:
        logger.info('Solution found: {}'.format(prog))
    else:
        logger.info('Solution not found!')


if __name__ == '__main__':
    logger.setLevel('DEBUG')
    assert len(argv) > 1
    main(argv[1])
