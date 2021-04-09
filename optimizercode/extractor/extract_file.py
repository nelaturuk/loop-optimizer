import os
import sys
from slither import Slither

from slither.core.cfg.node import NodeType
# from slither.detectors.abstract_detector import (AbstractDetector,
#                                                  DetectorClassification)
# from slither.slithir.operations import (HighLevelCall, LibraryCall, Call,
#                                         LowLevelCall, Send, Transfer)
# from slither.slithir.operations.condition import Condition
# from slither.analyses.data_dependency.data_dependency import is_tainted
# from slither.analyses.data_dependency.data_dependency import is_dependent

BENCHMARK_OUT_PATH = os.path.join('.', 'benchmarks')

new_contract='''
pragma solidity ^0.5.10;

contract C {{

  {global_vars}

  function foo() public {{
    {loop}
  }}
}}
'''

def main(fname):
    try:
        slither = Slither(fname)

        with open(fname, "r") as src_file:
            src = ''.join(src_file.readlines())
            for contract in slither.contracts:
                for function in contract.functions_declared:
                    extract_loops(contract, function, src)
    except Exception as e:
        print("FAILED TO RUN: {0}".format(fname))
        print(e)
    
def get_vars_decd(function, start, end):
    vs = []
    for node in function.nodes:
        if node.type == 0x13:
            start_idx = node.source_mapping["start"]
            if start_idx >= start and start_idx <= end:
                vs += node._vars_written

    return vs

def extract_loops(contract, function, src):
    global num_files
    for node in function.nodes:
        if node.type == NodeType.STARTLOOP:
            src_map = node.source_mapping
            start_idx = src_map["start"]
            length = src_map["length"]
            loop = src[start_idx:start_idx+length]
            # TODO: This is meant as a dumb approx for sifting only single-statement loops
            #       Currently 3 because for-loop already (usually) contains 2 in header
            # TODO: Sometimes loop ends up being empty? For now, adding on a check...
            if len(loop) > 0:
                print("**"*8)
                print(loop)
                print("**"*8)                
                vars_decd = get_vars_decd(function, start_idx, start_idx+length)
                loop_vars = set(filter(lambda x: x.name in loop and not x in vars_decd, function._vars_read_or_written))
                global_vars = ";\n  ".join(list(map(lambda x: str(x.type) + " " + str(x), loop_vars))) + ";"
                for var in loop_vars:
                    if "." in var.name:
                        global_vars = global_vars.replace(var.name, var.name.replace(".", "_"))
                        loop = loop.replace(var.name, var.name.replace(".", "_"))
                    if str(var.type) == "bytes":
                        global_vars = global_vars.replace(str(var.type), "mapping(uint => uint)")
                        
                extracted_contract = new_contract.format(global_vars=global_vars, loop=loop)
                print("--"*8)
                print(extracted_contract)
                print("--"*8)
                with open(os.path.join(BENCHMARK_OUT_PATH, "{0}_{1}_{2}.sol".format(contract.name, function.name, num_files)), 'w') as out_file:
                    out_file.write(extracted_contract)
                    num_files += 1

num_files = 0           
main(sys.argv[1])

# get_sol_files(BENCHMARK_IN_PATH)
