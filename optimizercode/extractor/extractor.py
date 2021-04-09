import argparse
import os
import json
import re

from stubs import erc20, erc20_vars, safemath
from collections import defaultdict

BENCHMARK_OUT_PATH = os.path.join('.', 'benchmarks')
BENCHMARK_IN_PATH = os.path.join('..', 'examples', 'safemath')

new_contract='''


{imports}

{safemath}

contract C {{
  {using}

  {structs}

  {global_vars}

  function foo() public {{
    {loop}
  }}

  {erc20_in}

}}

//#LOOPVARS: {loop_vars}

{erc20}
'''

extra_contract='''
contract {0} {{ }}
'''

safemath_skeleton='''
library SafeMath {{
  {body}
}}
'''

erc20_skeleton='''
contract {contract} {{
  {body}
}}
'''

solc4_command = os.path.join('/', 'usr', 'local', 'bin', 'solc-0.4')
solc5_command = os.path.join('/', 'usr', 'local', 'bin', 'solc-0.5')
sif_command = os.path.join('SIF', 'build', 'sif', 'sif')
null_out = os.path.join('/', 'dev', 'null')
temporary_json = os.path.join('.', 'tmp2.json')
temporary_ast = os.path.join('.', 'tmp2.ast')

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--file", help="solidity file path from which to extract a loop", type=str)
    parser.add_argument("--folder", help="folder from which to extract a loop", type=str)
    parser.add_argument("--replace_safemath", help="when activated, safemath ops will be replaced with regular operations", action="store_true")
    parser.add_argument("--add_safemath", help="when activated, safemath import will be added (at ./SafeMath.sol) if detected in loop and using clause for uint256 will be added", action="store_true")
    parser.add_argument("--stub_safemath", help="adds in stubs for safemath functions if used in loop",action="store_true")
    parser.add_argument("--stub_erc20", help="adds in stubs for known erc20 functions if used in loop (will even attempt other non-erc20 tokens)",action="store_true")    
    return parser.parse_args()

def main():
    global replace_safemath, add_safemath
    args = parse_args()
    if args.file:
        print("Extracting loop from {0}.".format(args.file))
        extract_loops(args.file, args)
    elif args.folder:
        print("Extracting loop from {0}.".format(args.folder))        
        extract_loops_from_folder(args.folder, args)

def get_var_types(types):
    all_types = []
    for typ in types:
        matches = re.findall(r"(mapping\((.*) => (.*)\))", typ)
        # TODO: handle nested mappings?
        if matches != []:
            typ1 = matches[0][1].replace("(", "").replace(")", "").replace("[]", "")
            typ2 = matches[0][2].replace("(", "").replace(")", "").replace("[]", "")
            all_types.append(typ1)
            all_types.append(typ2)
        else:
            if typ != "":
                typ = typ.replace("(", "").replace(")", "").replace("[]", "")
                all_types.append(typ)

    return list(set(all_types))

def should_be_filtered(loop_info, classic_types):
    safemath_funcs = ["add", "mul", "div", "sub", "mod"]    
    
    # Remove struct usage
    if loop_info.structs_used != [''] and loop_info.structs_used != []:
        print("Struct: {0}".format(loop_info.structs_used))
        return True

    # Remove returns
    if "return " in loop_info.source:
        print("Return")
        return True

    # Fetch function names and their callers
    func_caller_pairs = []
    for func in loop_info.funcs:
        func_caller_pairs += get_func_caller_pairs(func)

    # Remove external function calls
    for caller, func in func_caller_pairs:
        if not (func == "transfer" and (caller in loop_info.type_table or caller == "")) and not func in safemath_funcs and func != "require" and not func in classic_types:
            print("Func: {0}".format(func))
            return True
        
    # Remove nested mappings and multi-d arrays
    for var, typ in loop_info.type_table.items():
        if "[][]" in typ:
            print("2d array: {0} {1}".format(typ, var))
            return True
        if typ.count("mapping")+typ.count("[]") > 1:
            print("Nested mapping/array: {0} {1}".format(typ, var))
            return True
        
    return False

def extract_loop_info(sif_output):
    source = sif_output[0][0]
    info = sif_output[0][1]
    
    used = re.findall("USED: (.*)", info)[0].split(",")
    decd = re.findall("DECLARED: (.*)", info)[0].split(",")
    funcs = re.findall("FUNCTIONS: (.*)", info)[0].split("$$")
    events = re.findall("EVENTS: (.*)", info)[0].split("$$")    
    structs_used = re.findall("STRUCTS: (.*)", info)[0].split(",")
    it = re.findall("ITERATOR: (.*)", info)[0]
    size = int(re.findall("SIZE: (.*)", info)[0])
    loop_dec = int(re.findall("LOOP DEC: (.*)", info)[0])    

    structs_src = sif_output[0][2].split("$$$$$$$$$$$$$")
    
    return LoopInfo(used, decd, funcs, events, structs_used, it,
                    size, loop_dec, source, structs_src)

def is_int(s):
    try:
        int(s)
        return True
    except ValueError:
        return False

# def create_format_str(v, label):
#     if is_int(v):
#         return "{0}".format(label)

#     return "({0})".format(label)
    
def update_safemath(loop_info, uses_safemath):
    safemath_funcs = {"add": "+", "mul": "*", "div": "/", "sub": "-", "mod": "%"}

    # Keep track of all safemath calls
    safemath_calls = []
    # Sort function calls by length, so we know we replace shortest first
    funcs_called = sorted(loop_info.funcs, key=lambda x: len(x))

    for i, func_call in enumerate(funcs_called):
        for safe_func, repl in safemath_funcs.items():
            new_call = ""
            if func_call.startswith("SafeMath."):
                matches = re.findall(r"SafeMath.{0}\((.*), (.*)\)".format(safe_func),
                                     func_call)
                if matches:
                    lhs = matches[0][0]
                    rhs = matches[0][1]
                    # lhs_str = create_format_str(lhs, "{0}")
                    # rhs_str = create_format_str(rhs, "{2}")
                    # new_call_temp = "({0} {1} {2})".format(lhs_str, "{1}", rhs_str)
                    # new_call = new_call_temp.format(lhs,safemath_funcs[safe_func], rhs)
                    new_call = "(({0}) {1} ({2}))".format(lhs,safemath_funcs[safe_func], rhs)
                    safemath_calls.append((lhs, safe_func, rhs, func_call))                    
            else:
                splitter = ".{0}(".format(safe_func)           
                # If the safemath call is actually used in this function call
                if splitter in func_call:
                    split = func_call.split(splitter)
                    callee = split[0]
                    args = split[1][:-1]
                    # args_str = create_format_str(args, "{2}")
                    safemath_calls.append((callee, safe_func, args, func_call))
                    # new_call_temp = "({0} {1} {2})".format("({0})", "{1}", args_str)
                    # Also, go forward through the functions called, and replace this
                    #   in place, as when we go to split in future iterations, this will
                    #   complicate things
                    new_call = "(({0}) {1} ({2}))".format(callee,safemath_funcs[safe_func],
                                                    args)
            if new_call != "":
                for j in range(i+1, len(funcs_called)):
                    funcs_called[j] = funcs_called[j].replace(func_call, new_call)
                break                   

    # Do safemath adjustments if flags set and safemath functions used in loop
    if any(map(lambda x: x[1] in safemath_funcs, safemath_calls)):
        for (callee, func, args, old_call) in safemath_calls:
            # lhs_str = create_format_str(callee, "{0}")
            # rhs_str = create_format_str(args, "{2}")
            # new_call_temp = "({0} {1} {2})".format(lhs_str, "{1}", rhs_str)
            # new_call = new_call_temp.format(callee, safemath_funcs[func], args)
            new_call = "(({0}) {1} ({2}))".format(callee, safemath_funcs[func], args)
            loop_info.source = loop_info.source.replace(old_call, new_call)

def get_func_names(func_call):
    matches = re.findall(r"[^(]*\.([^(]*)\(", func_call)
    return matches

def get_func_caller_pairs(func_call):
    matches = re.findall(r"([^(]*)\.([^(]*)\(", func_call)
    # If there are no matches, check if it's a standalone function
    if matches == []:
        matches = get_standalone_func_name(func_call)
        matches = list(map(lambda x: ("", x), matches))
        
    return matches

def get_standalone_func_name(func_call):
    matches = re.findall(r"\A([^(]*)\(", func_call)
    return matches

def create_stub_safemath(loop_info):
    stubs = []

    # Fetch function names from function call-sites
    funcs_called = []
    for func in loop_info.funcs:
        funcs_called += get_func_names(func)

    for fname,stub in safemath.items():        
        # Only add stub function if it is in loop        
        if fname in funcs_called:
            stubs.append(stub)

    return "\n".join(stubs)
            
def create_stub_erc20(loop_info):
    stubs = defaultdict(set)    
    glob_vars = defaultdict(set)    

    # Fetch function names and their callers
    func_caller_pairs = []
    for func in loop_info.funcs:
        func_caller_pairs += get_func_caller_pairs(func)
        
    for caller, func in func_caller_pairs:
        if func in erc20 and (caller in loop_info.type_table or caller == ""):
            # Instance with standalone function, set typ to C for current contract
            if caller == "":
                typ = "C"
            else:
                typ = loop_info.type_table[caller]
            stubs[typ].add(erc20[func])
            glob_vars[typ] = set(list(glob_vars[typ]) + erc20_vars[func])

    for typ in stubs:
        stubs[typ] = "\n".join(list(glob_vars[typ]) + list(stubs[typ]))
        
    return stubs

def parse_sif_output(cname, output, args):
    contracts = {}
    filtered_contracts = {}
    
    # print(output)
    
    # Split output by loops (last is not loop, but global info, so separate out)
    loop_sep = "****************"
    loops = output.split(loop_sep)
    global_info = loops[-1]
    loops = loops[:-1]

    # Check if we use safemath
    uses_safemath = bool(int(re.findall("USES SAFEMATH: (.*)", global_info)[0]))

    # Imports and libraries used (initialized to empty)
    imports = ""
    using = ""
    
    # Add safemath if requested and actually used
    if uses_safemath and args.add_safemath:
        imports = 'import "./SafeMath.sol;"'
        using = "using SafeMath for uint256;"        
    
    for i,loop in enumerate(loops):
        sep = "=============="
        loop_parse = re.findall(r"{0}([\s\S]*){0}([\s\S]*){0}([\s\S]*){0}".format(sep), loop)
        source = loop_parse[0][0]

        # Extract relevant loop information
        loop_info = extract_loop_info(loop_parse)

        # Cosntruct all classic types
        uint_types = [uint+str(i*8) for i,uint in enumerate(["uint"]*33)]
        int_types = [intt+str(i*8) for i,intt in enumerate(["int"]*33)]        
        bytes_types = [byte+str(i) for i,byte in enumerate(["bytes"]*33)]
        classic_types = ["uint", "int", "byte", "bytes", "bool", "address"] + uint_types + int_types + bytes_types
        
        # Filter contract if it has one of our restricted things
        if should_be_filtered(loop_info, classic_types):
            print(loop_info.source)
            # Add new loop contract to filtered contracts, sorting by loop size
            if not loop_info.size in filtered_contracts:
                filtered_contracts[loop_info.size] = []        
            filtered_contracts[loop_info.size].append(source)
            continue
        
        # Extract types from mappings/arrays to add to all types
        all_var_types = get_var_types(loop_info.type_table.values())

        # Replace safemath if necessary
        if args.replace_safemath:
            update_safemath(loop_info, uses_safemath)

        # Add in stubs for erc20 and safemath as requested
        safemath_stub = ""
        erc20_stub = ""
        erc20_in = ""
        erc20_cls = []
        if args.stub_safemath:
            safemath_stub = create_stub_safemath(loop_info)
            if safemath_stub != "":
                safemath_stub = safemath_skeleton.format(body=safemath_stub)
        if args.stub_erc20:
            erc20_stubs = create_stub_erc20(loop_info)
            for cls, stub in erc20_stubs.items():
                if cls == "C":
                    erc20_in += stub
                else:
                    erc20_stub += erc20_skeleton.format(contract=cls, body=stub)
                    erc20_cls.append(cls)
                    
        # Add any user-defined contracts as necessary
        added_contracts = ""
        for var_type in all_var_types:
            if not var_type in classic_types+loop_info.structs_used+erc20_cls+["C"]:
                added_contracts += extra_contract.format(var_type)

        # Create global variable declarations
        all_vars = set([(typ, var) for (var, typ) in loop_info.type_table.items()])
        should_create_glob = lambda v: not v[1] in loop_info.decd and not (v[1] == loop_info.it and loop_info.loop_dec) and v[1] != "this" and v[1] != "super"
        vars_to_create = filter(should_create_glob, all_vars)
        global_vars = "\n".join(map(lambda y: "{0} {1};".format(y[0],y[1]), vars_to_create))
        
        # Plug the pieces into the contract
        extracted_contract = new_contract.format(global_vars=global_vars, loop=loop_info.source, imports=imports, using=using, loop_vars=loop_info.it, structs=loop_info.structs_source(), safemath=safemath_stub, erc20=erc20_stub, erc20_in=erc20_in)
        extracted_contract += added_contracts

        # Add new loop contract to contracts, sorting by loop size
        if not loop_info.size in contracts:
            contracts[loop_info.size] = []        
        contracts[loop_info.size].append((i, extracted_contract))
            
        print("--"*8)
        print(cname)
        print(loop_info.size)
        print("--"*8)
        print(extracted_contract)
        print("--"*8)

    return contracts, filtered_contracts

def extract_loops(cname, args):
    new_file = ""
    print("--"*8)
    print(cname)
    with open(cname, 'r') as c_file:
        pragma_set = False
        for line in c_file:
            if "pragma " in line and not pragma_set:
                pragma_set = True
                pragma = line[line.index("0."):]
                line = "pragma solidity ^0.5.10;\n"                
                if pragma.startswith("0.4"):
                    print("Using solc version 0.4")
                    solc_version = "0.4"
                    solc_command = solc4_command
                    line = "pragma solidity 0.4.25;\n"                                    
                elif pragma.startswith("0.5"):
                    print("Using solc version 0.5")        
                    solc_command = solc5_command
                else:
                    print("WARNING: pragma version {0} unrecognized. Using solc version 0.5.".format(pragma))
                    solc_command = solc5_command
            elif "pragma" in line and pragma_set:
                line = ""
                
            new_file += line
        if not pragma_set:
            new_file = "pragma solidity ^0.4.24;\n" + new_file
            solc_command = solc4_command
            solc_version = "0.4"

    with open(cname, 'w') as c_file:
        c_file.write(new_file)

    try:
        solc_json_command = '{0} --ast-compact-json {1}'.format(solc_command, cname)
        print("SOLC JSON COMMAND: {0}".format(solc_json_command))
        stream = os.popen(solc_json_command)
        solc_json_output = stream.read()
        solc_json_output = json.loads(solc_json_output[solc_json_output.index('{'):])
    except:
        return 0, 0, 0, 1
        
    # Add isConstructor field to FunctionDefinition for solc-0.5
    if solc_version == "0.5":
        for k in solc_json_output["nodes"]:
            if k["nodeType"] == "ContractDefinition":
                for k2 in k["nodes"]:
                    if k2["nodeType"] == "FunctionDefinition":
                        if not "isConstructor" in k2:
                            kind = k2["kind"]
                            k2["isConstructor"] = kind == "constructor"
                        

    with open(temporary_json, "w") as tmp_json:
        json_dict = json.dumps(solc_json_output)
        header = '''
        JSON AST (compact format):


        ======= {0} =======
        '''.format(cname)
        tmp_json.write(header)
        tmp_json.write(json_dict)

    # solc_ast_command = '{0} --ast {1} > {2}'.format(solc_command, cname, temporary_ast)
    # print("SOLC AST COMMAND: {0}".format(solc_ast_command))
    # os.system(solc_ast_command)

    # BEN HACK FIX STARTS FOR PROBLEM WITH uint[2]
    solc_ast_command = '{0} --ast {1}'.format(solc_command, cname)
    print("SOLC AST COMMAND: {0}".format(solc_ast_command))
    stream = os.popen(solc_ast_command)
    try:
        solc_ast_output = stream.read()
    except:
        return 0, 0, 0, 1
    lines_to_delete = []
    
    for i,line in enumerate(solc_ast_output.split("\n")):
        if "Type unknown." in line:
            lines_to_delete += [i-1, i, i+1]
            
    out_lines_ast = []
    for i,line in enumerate(solc_ast_output.split("\n")):
        if not i in lines_to_delete:
            out_lines_ast.append(line)

    out_ast = "\n".join(out_lines_ast)
    with open(temporary_ast, "w") as tmp_ast:
        tmp_ast.write(out_ast)
    # BEN HACK FIX ENDS FOR PROBLEM WITH uint[2]
        
    sif_run = '{0} -a {1} -j {2} -o {3}'.format(sif_command, temporary_ast, temporary_json, null_out)
    print("SIF COMMAND: {0}".format(sif_run))
    stream = os.popen(sif_run)
    sif_output = stream.read()
    
    if sif_output == "":
        print("FAILED TO USE SIF!")
        return 0,0,1,0

    contracts, filtered_contracts = parse_sif_output(cname, sif_output, args)

    if not os.path.exists(BENCHMARK_OUT_PATH):
        os.makedirs(BENCHMARK_OUT_PATH)

    cbasename = os.path.basename(cname)        
    for nl, conts in contracts.items():
        out_path = os.path.join(BENCHMARK_OUT_PATH, str(nl))
        if not os.path.exists(out_path):
            os.makedirs(out_path)

        for (i, cont) in conts:
            fname = "{0}_{1}.sol".format(cbasename.replace(".sol", ""), i)
            with open(os.path.join(out_path, fname), "w") as out_file:
                out_file.write(cont)

            print("Saved {0} in the folder {1}!".format(fname, out_path))

    return len(contracts.values()), len(filtered_contracts.values()), 0, 0
              

def extract_loops_from_folder(folder, args):
    tot_comp = 0
    tot_notcomp = 0
    tot_siffail = 0
    tot_astfail = 0
    tot_otherfail = 0
    for fname in os.listdir(folder):
        with open(os.path.join(folder,fname), "r") as src_file:
            src = ''.join(src_file.readlines())
            try:
                comp, notcomp, siffail, astfail = extract_loops(os.path.join(folder, fname), args)
                tot_comp += comp
                tot_notcomp += notcomp
                tot_siffail += siffail
                tot_astfail += astfail
            except Exception as e:
                print("Failed to compile {0}".format(fname))
                print(e)
                tot_otherfail += 1

    print("Filtered: {0}".format(tot_notcomp))
    print("Not Filtered: {0}".format(tot_comp))
    print("SIF Failed: {0}".format(tot_siffail))
    print("AST Failed: {0}".format(tot_astfail))
    print("Other Failed: {0}".format(tot_otherfail))
    print("Total: {0}".format(tot_comp+tot_notcomp+tot_siffail+tot_astfail+tot_otherfail))

class LoopInfo:

    def __init__(self, used, decd, funcs, events, structs_used,
                 it, size, loop_dec, source, structs_src):
        self.type_table = {}
        for entry in used:
            tup = re.findall("(.*):(.*)", entry)
            var = tup[0][0]
            typ = tup[0][1]
            self.type_table[var] = typ
        # Add this and super to type table, giving current contract as type
        self.type_table["this"] = "C"
        self.type_table["super"] = "C"

        self.used = self.type_table.keys()        
        self.decd = decd
        self.funcs = funcs
        self.events = events.sort(reverse=True)
        self.structs_used = structs_used
        self.it = it if it != "" else "i" # Default iterator is i if none found
        self.size = size
        self.loop_dec = bool(loop_dec)
        self.source = source
        self.structs_src = list(set(map(lambda s: s.replace("\n", ""), structs_src)))
        
        # Replace events with no-ops
        for event in events:
            self.source = self.source.replace(event, "");

        # Remove structs used for which analysis found no body
        self.structs_used = list(filter(lambda x: any(map(lambda y: x in y, self.structs_src)), self.structs_used))
        
    def structs_source(self):
        return "".join(self.structs_src)

                
main()
