from typing import List, Any
from tyrell.dsl import Node

from sys import argv
import tyrell.spec as S
from tyrell.interpreter import PostOrderInterpreter
from tyrell.enumerator.full_dsl_dependency_enumerator import DependencyEnumerator
from tyrell.enumerator import HoudiniEnumerator
from tyrell.decider import Example, BoundedModelCheckerDecider
from tyrell.synthesizer import Synthesizer
from tyrell.logger import get_logger
from slither.slither import Slither
from bmc import check_eq

import sys
sys.path.append("./analysis")

from analyze import analyze, analyze_lambdas, get_requires_conditions
from itertools import combinations, product 
import re
import time
import sys
from collections import defaultdict
import argparse

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
        iterator_vars = []
        if ind in body:
            # Parse syntax arround global variables
            iterator_vars = body[body.index(ind)+12:].split("\n")[0]
            iterator_vars = iterator_vars.replace('[', "").replace(']', "").replace("'", "").replace(" ", "").split(", ")
            # remove empty elements (occurs if no loop vars given
            iterator_vars = list(filter(lambda x: x != '', iterator_vars))
        if iterator_vars == []:
            # If analysis reported no loop variables, assume iterator is "i" and global
            iterator_vars = ["i"]

    return iterator_vars

def build_glob_decl(vars_map, iterator_var, i_global):
    glob_decl = ""
    for k,vs in vars_map.items():
        glob_decl += "".join(map(lambda v: "" if (v == iterator_var and not i_global)
                                 else k + ' ' + v + '; \n', vs)) 

    return glob_decl

def build_type_table(vars_map, all_types, map_types, other_contracts):
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
            typ = "mapping(uint => {0})".format(typ.replace("[]", ""))

        # Replace different bit amount variables with base version
        uint_types = [uint+str(i*8) for i,uint in enumerate(["uint"]*33)]
        int_types = [intt+str(i*8) for i,intt in enumerate(["int"]*33)]        
        bytes_types = [byte+str(i) for i,byte in enumerate(["bytes"]*33)]
        type_replacements = {"uint": uint_types+int_types,
                             "bytes": bytes_types}
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

            # add in other contract types to "Contract" for transfer
            #   TODO: I should probably restrict this to things called ERC20
            if typ in other_contracts:
                type_table["Contract"] += q_vars_list.split(",")
        else:
            print("IGNORED TYPE: {0}!".format(typ))

    return type_table

def fetch_int_constants(constants):
    extracted_ints = []
    for const in constants:
        try:
            int_const = '"{0}"'.format(int(const))
            extracted_ints.append(int_const)
        except:
            print("Ignoring {0} which is not int".format(const))

    return extracted_ints

def create_refinement_types(analysis, type_table, base_types):
    ref_types = ["Index", "Guard", "Read", "Write", "Constant", "GuardStart", "GuardEnd"]
    refinement_type_dict = {
        1: "Index",
        2: "Guard",
        3: "Read",
        4: "Write",
        5: "Constant",
        6: "GuardStart",
        7: "GuardEnd"
    }
    
    # Compute and store all combinations of refinements    
    comb_typs = []
    for i in range(0,len(ref_types)+1):
        comb_typs += combinations(ref_types, i)

    # extract ahead of time so in-time replacement in type_table doesn't break things
    type_table_contents = [(typ, list(vs)) for typ,vs in type_table.items()]
        
    # Iterate through dictionary of types --> var for base types (int, arr, etc.)
    for typ, vs in type_table_contents:
        for comb_typ in comb_typs:
            if comb_typ:
                final_typ = "{0}__{1}".format("_".join(comb_typ), typ)
            else:
                # No "__" if no refinement
                final_typ = typ
            if not final_typ in type_table:
                type_table[final_typ] = []        
            # Iterate through each variable
            for var in vs:
                quoted_var = var
                # Remove quotes
                var = var.replace('"', '')
                # Fetch var's refinements
                analysis_typs = []
                for ref_typ, ids in analysis.items():
                    if var in ids:
                        analysis_typs += [refinement_type_dict[ref_typ]]
                # Order refinements according to ref_typs
                analysis_typs = list(filter(lambda x: x in analysis_typs, ref_types))
                if all(map(lambda x: x in analysis_typs, list(comb_typ))):
                    type_table[final_typ].append(quoted_var)

    final_type_dict = {}
    # Remove empty entries from type table
    for typ, vs in type_table.items():
        if vs != []:
            # Remove duplicate entries if any
            final_type_dict[typ] = list(set(type_table[typ]))
        
    return final_type_dict

def add_sol_var_if_used(var, harness, type_table, typ):
    if var in map(str, harness.variables_read):
        type_table[typ] = list(set(type_table[typ]+['"{0}"'.format(var)]))

    return type_table

def instantiate_dsl(sol_file, analysis, lambdas, req_conds, prune):
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
    for var in harness_fun.state_variables_read:
        add_var(vars_map, var)

    for var in harness_fun.state_variables_written:
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
    type_table = build_type_table(vars_map, all_types, map_types, other_contracts)

    # Copy global integers into special separate type "g_int"
    if type_table["uint"] != []:            
        type_table["g_int"] = list(set(type_table["uint"]))

    # Fetch integer constant values
    C = fetch_int_constants(analysis[5]) #if prune else []        
    # Add 0 and 1 and remove duplicates
    C = list(set(C+['"0"', '"1"']))
    # Non-zero constants
    nonzero_C = list(filter(lambda x: x != '"0"', C))
    # Boolean constants
    # B = ['"true"', '"false"']
    # (quick-fix) directly use 0 (resp. 1) to represent false (resp. true) (as they are in RosetteIR)
    B = ['"1"', '"0"']
    
    # Add int constants separately for DSL where only constants are needed
    type_table["C"] = C
    # Non-zero values for div and mul
    type_table["nonzero_uint"] = list(set(type_table["uint"]+nonzero_C))
    # Add int constants to ints
    type_table["uint"] = list(set(type_table["uint"]+C))
        
    # Add in now and msg.value if used
    type_table = add_sol_var_if_used("now", harness_fun, type_table, "uint")
    type_table = add_sol_var_if_used("msg.value", harness_fun, type_table, "uint")

    # Add "true" and "false" as boolean constants
    type_table["bool"] = list(set(type_table["bool"]+B))
    # Add 0 address to addresses
    # type_table["address"] = list(set(type_table["address"]+['"address(0)"']))
    # (quick-fix) directly use 0 to represent address constant (as it is in RosetteIR)
    type_table["address"] = list(set(type_table["address"]+['"0"']+C))

    # Add msg.sender if used
    type_table = add_sol_var_if_used("msg.sender", harness_fun, type_table, "address")
        
    # Add in lambdas if present
    if (lambdas):
        type_table["Lambda"] = list(map(lambda x: '"{0}"'.format(x), lambdas))

    # Add requires conditions if present
    if (req_conds):
        type_table["ReqCond"] = list(map(lambda x: '"{0}"'.format(x), req_conds))
        
    if prune:
        # Create and add in refinement types from analysis        
        type_table = create_refinement_types(analysis, type_table, base_types)
    else:
        # Remove refinement types from dsl
        actual_spec = remove_refinement(actual_spec)
        # Add in arithmetic lambda funcs
        actual_spec += '''
func add: L -> uint;
func mul: L -> nonzero_uint;
func sub: L -> uint;
func div: L -> nonzero_uint;
        '''
        # Use filter conditional for require as well as filter
        actual_spec = actual_spec.replace("ReqCond", "Cond")        
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
    
    return actual_spec, glob_decl, type_table, i_global, [iterator_var]

def get_base_type(typ):
    if not "__" in typ:
        return typ

    return typ.split("__")[1]

def remove_refinement(dsl):
    new_dsl = []
    for line in dsl.split("\n"):
        if line.startswith("func"):
            # extract arg types
            args = line.split("->")[1][:-1].split(",")            
            for arg in args:
                # replace map types first
                matches = re.findall(r"(mapping\((.*) => (.*)\))", arg)                
                if matches:
                    dom = matches[0][1]
                    codom = matches[0][2]
                    new_dom = get_base_type(dom)
                    new_codom = get_base_type(codom)
                    new_arg = "mapping({0} => {1})".format(new_dom, new_codom)
                    line = line.replace(matches[0][0], new_arg)

                # replace parent type
                line = line.replace(arg, get_base_type(arg))

            # Write adjusted func line
            new_dsl.append(line)
        else:
            # Write all non-func lines
            new_dsl.append(line)
            
    return "\n".join(new_dsl)

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

dsl_skeleton ='''
{types}

value L;
value IF;
value i;
value i_st;
value i_end;
value F;
value Cond_uint;
value Cond_address;
value Summary;
value Inv;

program SolidityLoops() -> Summary;

func summarize: Summary -> Inv, i_st, i_end;
func summarize_nost: Summary -> Inv, i_end;

# func seqF: Inv -> F, Inv;
# func seqIF: Inv -> IF, Inv;

func intFunc: Inv -> IF;
func nonintFunc: Inv -> F;

# DSL Functions (with lambda versions when appropriate)
func SUM_L: IF -> Write__g_int, Read__mapping(uint => uint), L;
func SUM: IF -> Write__g_int, Read__mapping(uint => uint);
func SUB_L: IF -> Write__g_int, Read__mapping(uint => uint), L;
func SUB: IF -> Write__g_int, Read__mapping(uint => uint);
func MUL_L: IF -> Write__g_int, Read__mapping(uint => uint), L;
func MUL: IF -> Write__g_int, Read__mapping(uint => uint);
func DIV_L: IF -> Write__g_int, Read__mapping(uint => uint), L;
func DIV: IF -> Write__g_int, Read__mapping(uint => uint);
func COPYRANGE_L: IF -> Read__mapping(uint => uint), i, Write__mapping(uint => uint), L;
func COPYRANGE__#A: IF -> Read__mapping(uint => #A), i, Write__mapping(uint => #A);
func MAP_L: IF -> Read_Write__mapping(uint => uint), L;
func MAP__#A: F -> Write__mapping(uint => #A), Read__#A;
func UPDATERANGE__#A_#B: F -> Index_Read__mapping(uint => #A), Write__mapping(#A => #B), Read__#B;
func UPDATERANGE_L: F -> Index_Read__mapping(uint => address), Write__mapping(address => uint), L;

# Arithmetic funcs for lambda
# func lambda: L -> Lambda;

# Add constant for global integers
func addc: i -> g_int, C;
func subc: i -> g_int, C;
func const: i -> C;
func addc_st: i_st -> GuardStart__uint, C;
func addc_end: i_end -> GuardEnd__uint, C;
func subc_st: i_st -> GuardStart__uint, C;
func subc_end: i_end -> GuardEnd__uint, C;

# Boolean comps for uint
func lt: Cond_uint -> mapping(uint => uint), uint;
func gt: Cond_uint -> mapping(uint => uint), uint;
func eq: Cond_uint -> mapping(uint => uint), uint;
func neq: Cond_uint -> mapping(uint => uint), uint;
func lte: Cond_uint -> mapping(uint => uint), uint;
func gte: Cond_uint -> mapping(uint => uint), uint;
func bool_arrT: Cond_uint -> mapping(uint => bool);
func bool_arrF: Cond_uint -> mapping(uint => bool);

# Boolean compus for uint w/ nested array access
func lt2: Cond_uint -> mapping(uint => address), mapping(address => uint), uint;
func gt2: Cond_uint -> mapping(uint => address), mapping(address => uint), uint;
func eq2: Cond_uint -> mapping(uint => address), mapping(address => uint), uint;
func neq2: Cond_uint -> mapping(uint => address), mapping(address => uint), uint;
func lte2: Cond_uint -> mapping(uint => address), mapping(address => uint), uint;
func gte2: Cond_uint -> mapping(uint => address), mapping(address => uint), uint;
func bool_arrT2: Cond_uint -> mapping(uint => address), mapping(address => bool);
func bool_arrF2: Cond_uint -> mapping(uint => address), mapping(address => bool);

# Boolean comps for address
func eq_addr: Cond_address -> mapping(uint => address), address;
func neq_addr: Cond_address -> mapping(uint => address), address;
'''

class SymDiffInterpreter(PostOrderInterpreter):

    program_decl = ""

    contract_prog = """pragma solidity ^0.5.10;

        contract C {{
            
            {structs}

            {_decl}

            {other_decs}

            function foo() public {{
                
                {_body}

            }}

            {other_funcs}
        }}

        {other_contracts}

    """

    extra_contract = """
    contract {0} {{{{ }}}}
    """

    # pc counter, self.pc
    pc = 0

    def __init__(self, decl="", contracts=[], i_global=False, global_vars=["i"], structs="", timeout=-1):
        # for contract in contracts:
        #     self.contract_prog += self.extra_contract.format(contract)
        self.other_contracts = contracts
        self.program_decl = decl
        self.i_typ = "" if i_global else "uint"
        # TODO: HANDLE NESTED LOOPS
        self.iterator = global_vars[0]
        self.structs = structs
        self.other_funcs = set()
        self.other_decs = set()

        self._ref_counter = -1 # reference variable counter
        self._tmp_counter = -1 # temporary variable counter
        self._ckpt_counter = -1 # checkpoint variable counter (for require method)
        self._tnsf_counter = -1 # transfer result counter (for transfer method)

        self._read_list = [] # temporary list to track variables being read in one full eval
        self._write_list = [] # temporary list to track variables being written in one full eval
        self._ckpt_list = []

        self.timeout = timeout
        self._start_time = time.time()

    def get_fresh_ref_name(self):
        self._ref_counter += 1
        return "REF_{}".format(self._ref_counter)

    def get_fresh_tmp_name(self):
        # (notice) fresh tmp name is only for those instructions that
        # 1) do not need the return values (e.g., array-write)
        # 2) do not care about the target value (e.g., int i; in for where i has no initial value)
        # otherwise, please use other get_fresh methods
        self._tmp_counter += 1
        return "TMP_{}".format(self._tmp_counter)

    def get_fresh_ckpt_name(self):
        # (notice) fresh checkpoint name for `require` method
        # in bmc, this variable is added to the verification pool
        # and two programs should use DIFFERENT symbolic variables to store checkpoints
        # (important) _ckpt_counter is local to every eval
        # so it should be reset to -1 before every eval
        self._ckpt_counter += 1
        return "CKPT_{}".format(self._ckpt_counter)

    def get_fresh_tnsf_name(self):
        self._tnsf_counter += 1
        return "TNSF_{}".format(self._tnsf_counter)

    # overridding the eval method by adding one extra call to reset _ckpt_counter
    # (important) since ckpt checking in rosette side is order sensitive
    # and decider is relying on exact matching of ckpt names
    def eval(self, prog: Node, inputs: List[Any]) -> Any:
        if self.timeout>=0:
            if time.time()-self._start_time>self.timeout:
                logger.info("Timeout.")
                sys.exit(0)

        self._ckpt_counter = -1 # reset _ckpt_counter
        self._tnsf_counter = -1 # reset _tnsf_counter

        self._read_list = [] # reset read list
        self._write_list = [] # reset write list
        self._ckpt_list = []
        return super(SymDiffInterpreter, self).eval(prog, inputs)

    #########################################
    # Conditional Operators
    #########################################

    def get_nested_access(self, args):
        # srcArr[indexArr[it]] op srcVal
        # srcArr = args[0]
        # indexArr = args[1]
        # (notice) somewhat the indexArr is args[0] and srcArr is args[1] though
        indexArr = args[0]
        srcArr = args[1]
        it = self.iterator
        meta_list = []

        inst = "{}: {} = {{GuardStart}}".format( hex(self.pc), it )
        meta_list.append(inst)
        self.pc += 1

        # ref_0 = indexArr[it]
        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, indexArr, it )
        meta_list.append(inst)
        self.pc += 1

        # ref_1 = srcArr[ref_0]
        ref_1 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_1, srcArr, ref_0 )
        meta_list.append(inst)
        self.pc += 1

        self._read_list += [indexArr, srcArr]
        return meta_list, ref_1

    def eval_lt2(self, node, args):
        srcVal = args[2]
        meta_list, ref_1 = self.get_nested_access(args)
        # srcArr[indexArr[it]] < srcVal
        prev_list = [] + meta_list

        # ref_1 < srcVal
        expr = "LT {} {}".format( ref_1, srcVal )
        self._read_list += [srcVal]
        return prev_list, expr

    def eval_lte2(self, node, args):
        srcVal = args[2]
        meta_list, ref_1 = self.get_nested_access(args)
        # srcArr[indexArr[it]] <= srcVal
        prev_list = [] + meta_list

        # ref_1 <= srcVal
        expr = "LTE {} {}".format( ref_1, srcVal )
        self._read_list += [srcVal]
        return prev_list, expr

    def eval_eq2(self, node, args):
        srcVal = args[2]
        meta_list, ref_1 = self.get_nested_access(args)
        # srcArr[indexArr[it]] == srcVal
        prev_list = [] + meta_list

        # ref_1 == srcVal
        expr = "EQ {} {}".format( ref_1, srcVal )
        self._read_list += [srcVal]
        return prev_list, expr
     
    def eval_neq2(self, node, args):
        srcVal = args[2]
        meta_list, ref_1 = self.get_nested_access(args)
        # srcArr[indexArr[it]] != srcVal
        prev_list = [] + meta_list

        # ref_1 != srcVal
        expr = "NEQ {} {}".format( ref_1, srcVal )
        self._read_list += [srcVal]
        return prev_list, expr
    
    def eval_gt2(self, node, args):
        srcVal = args[2]
        meta_list, ref_1 = self.get_nested_access(args)
        # srcArr[indexArr[it]] > srcVal
        prev_list = [] + meta_list

        # ref_1 > srcVal
        expr = "GT {} {}".format( ref_1, srcVal )
        self._read_list += [srcVal]
        return prev_list, expr
    
    def eval_gte2(self, node, args):
        srcVal = args[2]
        meta_list, ref_1 = self.get_nested_access(args)
        # srcArr[indexArr[it]] >= srcVal
        prev_list = [] + meta_list

        # ref_1 >= srcVal
        expr = "GTE {} {}".format( ref_1, srcVal )
        self._read_list += [srcVal]
        return prev_list, expr

    def eval_bool_arrT2(self, node, args):
        meta_list, ref_1 = self.get_nested_access(args)
        # srcArr[indexArr[it]] == true
        prev_list = [] + meta_list

        # ref_1 
        expr = "{}".format( ref_1 )
        return prev_list, expr
    
    def eval_bool_arrF2(self, node, args):
        meta_list, ref_1 = self.get_nested_access(args)
        # srcArr[indexArr[it]] == false
        prev_list = [] + meta_list

        # NOT ref_1 
        expr = "NOT {}".format( ref_1 )
        return prev_list, expr

    ### (important)
    ### Cond_uint only appears in REQUIRE (both eval_op and eval_op2 series)
    ### so it's safe to add "it={{GuardStart}}" inside Cond_uint
        
    def eval_lt(self, node, args):
        # srcArr[it] < srcVal
        srcArr = args[0]
        srcVal = args[1]
        it = self.iterator
        prev_list = []

        inst = "{}: {} = {{GuardStart}}".format( hex(self.pc), it )
        prev_list.append(inst)
        self.pc += 1

        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, srcArr, self.iterator )
        prev_list.append(inst)
        self.pc += 1

        expr = "LT {} {}".format( ref_0, srcVal )
        self._read_list += [srcArr, srcVal]
        return prev_list, expr

    def eval_lte(self, node, args):
        # srcArr[it] <= srcVal
        srcArr = args[0]
        srcVal = args[1]
        it = self.iterator
        prev_list = []

        inst = "{}: {} = {{GuardStart}}".format( hex(self.pc), it )
        prev_list.append(inst)
        self.pc += 1

        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, srcArr, self.iterator )
        prev_list.append(inst)
        self.pc += 1

        expr = "LTE {} {}".format( ref_0, srcVal )
        self._read_list += [srcArr, srcVal]
        return prev_list, expr

    def eval_eq(self, node, args):
        # srcArr[it] == srcVal
        srcArr = args[0]
        srcVal = args[1]
        it = self.iterator
        prev_list = []

        inst = "{}: {} = {{GuardStart}}".format( hex(self.pc), it )
        prev_list.append(inst)
        self.pc += 1

        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, srcArr, self.iterator )
        prev_list.append(inst)
        self.pc += 1

        expr = "EQ {} {}".format( ref_0, srcVal )
        self._read_list += [srcArr, srcVal]
        return prev_list, expr
    
    def eval_neq(self, node, args):
        # srcArr[it] != srcVal
        srcArr = args[0]
        srcVal = args[1]
        it = self.iterator
        prev_list = []

        inst = "{}: {} = {{GuardStart}}".format( hex(self.pc), it )
        prev_list.append(inst)
        self.pc += 1

        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, srcArr, self.iterator )
        prev_list.append(inst)
        self.pc += 1

        expr = "NEQ {} {}".format( ref_0, srcVal )
        self._read_list += [srcArr, srcVal]
        return prev_list, expr
    
    def eval_gt(self, node, args):
        # srcArr[it] > srcVal
        srcArr = args[0]
        srcVal = args[1]
        it = self.iterator
        prev_list = []

        inst = "{}: {} = {{GuardStart}}".format( hex(self.pc), it )
        prev_list.append(inst)
        self.pc += 1

        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, srcArr, self.iterator )
        prev_list.append(inst)
        self.pc += 1

        expr = "GT {} {}".format( ref_0, srcVal )
        self._read_list += [srcArr, srcVal]
        return prev_list, expr
    
    def eval_gte(self, node, args):
        # srcArr[it] >= srcVal
        srcArr = args[0]
        srcVal = args[1]
        it = self.iterator
        prev_list = []

        inst = "{}: {} = {{GuardStart}}".format( hex(self.pc), it )
        prev_list.append(inst)
        self.pc += 1

        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, srcArr, self.iterator )
        prev_list.append(inst)
        self.pc += 1

        expr = "GTE {} {}".format( ref_0, srcVal )
        self._read_list += [srcArr, srcVal]
        return prev_list, expr

    def eval_bool_arrT(self, node, args):
        # ref_0 = srcArr[it]
        # ref_0
        srcArr = args[0]
        it = self.iterator
        prev_list = []

        inst = "{}: {} = {{GuardStart}}".format( hex(self.pc), it )
        prev_list.append(inst)
        self.pc += 1

        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, srcArr, it )
        prev_list.append(inst)
        self.pc += 1

        expr = "{}".format( ref_0 )
        self._read_list += [srcArr]
        return prev_list, expr
    
    def eval_bool_arrF(self, node, args):
        # ref_0 = srcArr[it]
        # NOT ref_0
        srcArr = args[0]
        it = self.iterator
        prev_list = []

        inst = "{}: {} = {{GuardStart}}".format( hex(self.pc), it )
        prev_list.append(inst)
        self.pc += 1

        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, srcArr, it )
        prev_list.append(inst)
        self.pc += 1

        expr = "NOT {}".format( ref_0 )
        self._read_list += [srcArr]
        return prev_list, expr

    def eval_eq_addr(self, node, args):
        # srcArr[it] == srcAddr
        srcArr = args[0]
        addrStr = args[1]
        it = self.iterator
        prev_list = []

        inst = "{}: {} = {{GuardStart}}".format( hex(self.pc), it )
        prev_list.append(inst)
        self.pc += 1

        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, srcArr, it )
        prev_list.append(inst)
        self.pc += 1

        # FIXME (including bmc): not an exact method to extract/represent address
        srcAddr = addrStr.replace("address(","").replace(")","")
        expr = "EQ {} {}".format( ref_0, srcAddr )
        self._read_list += [srcArr, srcAddr]
        return prev_list, expr
    
    def eval_neq_addr(self, node, args):
        # srcArr[it] != srcAddr
        srcArr = args[0]
        addrStr = args[1]
        it = self.iterator
        prev_list = []

        inst = "{}: {} = {{GuardStart}}".format( hex(self.pc), it )
        prev_list.append(inst)
        self.pc += 1

        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, srcArr, it )
        prev_list.append(inst)
        self.pc += 1

        # FIXME (including bmc): not an exact method to extract/represent address
        srcAddr = addrStr.replace("address(","").replace(")","")
        expr = "NEQ {} {}".format( ref_0, srcAddr )
        self._read_list += [srcArr, srcAddr]
        return prev_list, expr
    
    def eval_addc(self, node, args):
        self._read_list += [args[0], args[1]]
        return "ADD {} {}".format(args[0], args[1])

    def eval_addc_st(self, node, args):
        self._read_list += [args[0], args[1]]
        return "ADD {} {}".format(args[0], args[1])

    def eval_addc_end(self, node, args):
        self._read_list += [args[0], args[1]]
        return "ADD {} {}".format(args[0], args[1])

    def eval_subc(self, node, args):
        self._read_list += [args[0], args[1]]
        return "SUB {} {}".format(args[0], args[1])

    def eval_subc_st(self, node, args):
        self._read_list += [args[0], args[1]]
        return "SUB {} {}".format(args[0], args[1])

    def eval_subc_end(self, node, args):
        self._read_list += [args[0], args[1]]
        return "SUB {} {}".format(args[0], args[1])

    #########################################
    # Lambda operators
    #########################################

    # Ben says don't use this one
    # def eval_lambda(self, node, args):
    #     return args[0].split(":")[1].replace(" ", "")
        
    # def eval_const(self, node, args):
    #     print("eval_const args: {}".format(args))
    #     # we know this is constant already
    #     vconstant = args[0]
    #     rmap = {"true":1, "false":0, "address(0)":0}
    #     if vconstant in rmap.keys():
    #         rconstant = rmap[vconstant]
    #     else:
    #         rconstant = vconstant
    #     self._read_list += [rconstant]
    #     return args[rconstant]

    def eval_const(self, node, args):
        self._read_list += [args[0]]
        return args[0]

    def eval_add(self, node, args):
        # return "__x" + '+' + args[0]
        if args[0] == "-1":
            # return "__x-1"
            self._read_list += ["1"]
            return "SUB {} {}".format("__x", "1")
        # return "__x" + '+' + args[0]
        self._read_list += [args[0]]
        return "ADD {} {}".format("__x", args[0])

    def eval_sub(self, node, args):
        self._read_list += [args[0]]
        return "SUB {} {}".format("__x", args[0])

    def eval_mul(self, node, args):
        self._read_list += [args[0]]
        return "MUL {} {}".format("__x", args[0])
    
    def eval_div(self, node, args):
        self._read_list += [args[0]]
        return "DIV {} {}".format("__x", args[0])

    #########################################
    # DSL
    #########################################
    def build_sum(self, node, args, l, nested, op):
        # print("build_sum args: {}".format(args))
        # print("build_sum l: {}".format(l))
        # print("build_sum nested: {}".format(nested))
        tgtAcc = args[0]
        srcArr = args[1]
        Lam = args[2] if l else None
        if nested:
            indexArr = args[3] if l else args[2]
        else:
            indexArr = None
        it = self.iterator
        # build_sum is doing: 
        # 1 (nested+lambda). tgtAcc += Lam( srcArr[indexArr[it]] )
        # 2 (nested only).   tgtAcc += srcArr[indexArr[it]]
        # 3 (lambda only).   tgtAcc += Lam( srcArr[it] )
        # 4 ().              tgtAcc += srcArr[it]

        # FIXME: missing initialization expression outside the loop body
        inst_list = []

        # e.g., self.iterator = {{GuardStart}}
        inst = "{}: {} = {{GuardStart}}".format(hex(self.pc), it)
        inst_list.append(inst)
        self.pc += 1

        ref_0 = self.get_fresh_ref_name()
        if nested:
            # ref_0 = indexArr[it]
            inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, indexArr, it )
        else:
            # ref_0 = it
            inst = "{}: {} = {}".format( hex(self.pc), ref_0, it )
        inst_list.append(inst)
        self.pc += 1

        # ref_1 = srcArr[ref_0]
        ref_1 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_1, srcArr, ref_0 )
        inst_list.append(inst)
        self.pc += 1

        ref_2 = self.get_fresh_ref_name()
        if l:
            # ref_2 = Lam(ref_1)
            inst = "{}: {} = {}".format( hex(self.pc), ref_2, Lam.replace("__x", ref_1) )
        else:
            # ref_2 = ref_1
            inst = "{}: {} = {}".format( hex(self.pc), ref_2, ref_1 )
        inst_list.append(inst)
        self.pc += 1

        # tgtAcc = tgtAcc + ref_2
        if (op == 'SUM'):
            inst = "{}: {} = ADD {} {}".format( hex(self.pc), tgtAcc, tgtAcc, ref_2 )
        if (op == 'SUB'):
            inst = "{}: {} = SUB {} {}".format( hex(self.pc), tgtAcc, tgtAcc, ref_2 )
        if (op == 'MUL'):
            inst = "{}: {} = MUL {} {}".format( hex(self.pc), tgtAcc, tgtAcc, ref_2 )
        if (op == 'DIV'):
            inst = "{}: {} = DIV {} {}".format( hex(self.pc), tgtAcc, tgtAcc, ref_2 )
        inst_list.append(inst)
        self.pc += 1

        if nested and l:
            self._read_list += [srcArr, indexArr, tgtAcc]
            self._write_list += [tgtAcc]
        elif nested and (not l):
            self._read_list += [srcArr, indexArr, tgtAcc]
            self._write_list += [tgtAcc]
        elif (not nested) and l:
            self._read_list += [srcArr, tgtAcc]
            self._write_list += [tgtAcc]
        else:
            self._read_list += [srcArr, tgtAcc]
            self._write_list += [tgtAcc]

        return inst_list

    def eval_SUM(self, node, args):
        return self.build_sum(node, args, False, False, 'SUM')

    def eval_SUM_L(self, node, args):
        return self.build_sum(node, args, True, False, 'SUM')
    
    def eval_NESTED_SUM(self, node, args):
        return self.build_sum(node, args, False, True, 'SUM')

    def eval_NESTED_SUM_L(self, node, args):
        return self.build_sum(node, args, True, True, 'SUM')

    def eval_SUB(self, node, args):
        return self.build_sum(node, args, False, False, 'SUB')

    def eval_SUB_L(self, node, args):
        return self.build_sum(node, args, True, False, 'SUB')
    
    def eval_NESTED_SUB(self, node, args):
        return self.build_sum(node, args, False, True, 'SUB')

    def eval_NESTED_SUB_L(self, node, args):
        return self.build_sum(node, args, True, True, 'SUB')

    def eval_MUL(self, node, args):
        return self.build_sum(node, args, False, False, 'MUL')

    def eval_MUL_L(self, node, args):
        return self.build_sum(node, args, True, False, 'MUL')
    
    def eval_NESTED_MUL(self, node, args):
        return self.build_sum(node, args, False, True, 'MUL')

    def eval_NESTED_MUL_L(self, node, args):
        return self.build_sum(node, args, True, True, 'MUL')

    def eval_DIV(self, node, args):
        return self.build_sum(node, args, False, False, 'DIV')

    def eval_DIV_L(self, node, args):
        return self.build_sum(node, args, True, False, 'DIV')
    
    def eval_NESTED_DIV(self, node, args):
        return self.build_sum(node, args, False, True, 'DIV')

    def eval_NESTED_DIV_L(self, node, args):
        return self.build_sum(node, args, True, True, 'DIV')

    def build_copyrange(self, node, args, l, nested):   
        # print("build_copyrange args: {}".format(args))
        # print("build_copyrange l: {}".format(l))
        # print("build_copyrange nested: {}".format(nested))  
        srcArr = args[0]
        srcStart = args[1]
        tgtArr = args[2]
        Lam = args[3] if l else None
        if nested:
            indexArr = args[4] if l else args[3]
        else:
            indexArr = None
        it = self.iterator
        # build_copyrange is doing: 
        # 1 (nested+lambda). tgtArr[indexArr[it]] = Lam( srcArr[it+srcStart] )
        # 2 (nested only).   tgtArr[indexArr[it]] = srcArr[it+srcStart]
        # 3 (lambda only).   tgtArr[it] = Lam( srcArr[it+srcStart] )
        # 4 ().              tgtArr[it] = srcArr[it+srcStart]

        inst_list = []

        # e.g., self.iterator = {{GuardStart}}
        inst = "{}: {} = {{GuardStart}}".format(hex(self.pc), it)
        inst_list.append(inst)
        self.pc += 1

        # ref_ss = srcStart, expands the srcStart since it may be an expression
        ref_ss = self.get_fresh_ref_name()
        inst = "{}: {} = {}".format( hex(self.pc), ref_ss, srcStart )
        inst_list.append(inst)
        self.pc += 1

        # ref_0 = it+ref_ss
        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ADD {} {}".format( hex(self.pc), ref_0, it, ref_ss )
        inst_list.append(inst)
        self.pc += 1

        # ref_1 = srcArr[ref_0]
        ref_1 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_1, srcArr, ref_0 )
        inst_list.append(inst)
        self.pc += 1

        ref_2 = self.get_fresh_ref_name()
        if l:
            # ref_2 = Lam( ref_1 )
            inst = "{}: {} = {}".format( hex(self.pc), ref_2, Lam.replace("__x", ref_1) )
        else:
            # ref_2 = ref_1
            inst = "{}: {} = {}".format( hex(self.pc), ref_2, ref_1 )
        inst_list.append(inst)
        self.pc += 1

        ref_3 = self.get_fresh_ref_name()
        if nested:
            # ref_3 = indexArr[it]
            inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_3, indexArr, it )
        else:
            # ref_3 = it
            inst = "{}: {} = {}".format( hex(self.pc), ref_3, it )
        inst_list.append(inst)
        self.pc += 1

        # tgtArr[ref_3] = ref_2
        tmp_4 = self.get_fresh_tmp_name()
        inst = "{}: {} = ARRAY-WRITE {} {} {}".format( hex(self.pc), tmp_4, tgtArr, ref_3, ref_2 )
        inst_list.append(inst)
        self.pc += 1

        if nested and l:
            # self._read_list += [srcArr, srcStart, indexArr]
            # quick-fix <type i>: no need to include srcStart any more as it's processed in const/addc/...
            self._read_list += [srcArr, indexArr]
            self._write_list += [tgtArr]
        elif nested and (not l):
            # self._read_list += [srcArr, srcStart, indexArr]
            # quick-fix <type i>: no need to include srcStart any more as it's processed in const/addc/...
            self._read_list += [srcArr, indexArr]
            self._write_list += [tgtArr]
        elif (not nested) and l:
            # self._read_list += [srcArr, srcStart]
            # quick-fix <type i>: no need to include srcStart any more as it's processed in const/addc/...
            self._read_list += [srcArr]
            self._write_list += [tgtArr]
        else:
            # self._read_list += [srcArr, srcStart]
            # quick-fix <type i>: no need to include srcStart any more as it's processed in const/addc/...
            self._read_list += [srcArr]
            self._write_list += [tgtArr]

        return inst_list
    
    def eval_COPYRANGE(self, node, args):
        return self.build_copyrange(node, args, False, False)

    def eval_COPYRANGE_L(self, node, args):
        return self.build_copyrange(node, args, True, False)

    def eval_NESTED_COPYRANGE(self, node, args):
        return self.build_copyrange(node, args, False, True)

    def eval_NESTED_COPYRANGE_L(self, node, args):
        return self.build_copyrange(node, args, True, True)

    def build_incrange(self, node, args, l, nested):        
        # print("build_incrange args: {}".format(args))
        # print("build_incrange l: {}".format(l))
        # print("build_incrange nested: {}".format(nested))  
        srcArr = args[0]
        srcStart = args[1]
        tgtArr = args[2]
        Lam = args[3] if l else None
        if nested:
            indexArr = args[4] if l else args[3]
        else:
            indexArr = None
        it = self.iterator
        # build_incrange is doing: 
        # 1 (nested+lambda). tgtArr[indexArr[it]] += Lam( srcArr[it+srcStart] )
        # 2 (nested only).   tgtArr[indexArr[it]] += srcArr[it+srcStart]
        # 3 (lambda only).   tgtArr[it] += Lam( srcArr[it+srcStart] )
        # 4 ().              tgtArr[it] += srcArr[it+srcStart]

        inst_list = []

        # e.g., self.iterator = {{GuardStart}}
        inst = "{}: {} = {{GuardStart}}".format(hex(self.pc), it)
        inst_list.append(inst)
        self.pc += 1

        # ref_ss = srcStart, expands the srcStart since it may be an expression
        ref_ss = self.get_fresh_ref_name()
        inst = "{}: {} = {}".format( hex(self.pc), ref_ss, srcStart )
        inst_list.append(inst)
        self.pc += 1

        # ref_0 = it+srcStart
        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ADD {} {}".format( hex(self.pc), ref_0, it, ref_ss )
        inst_list.append(inst)
        self.pc += 1

        # ref_1 = srcArr[ref_0]
        ref_1 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_1, srcArr, ref_0 )
        inst_list.append(inst)
        self.pc += 1

        ref_2 = self.get_fresh_ref_name()
        if l:
            # ref_2 = Lam( ref_1 )
            inst = "{}: {} = {}".format( hex(self.pc), ref_2, Lam.replace("__x", ref_1) )
        else:
            # ref_2 = ref_1
            inst = "{}: {} = {}".format( hex(self.pc), ref_2, ref_1 )
        inst_list.append(inst)
        self.pc += 1

        ref_3 = self.get_fresh_ref_name()
        if nested:
            # ref_3 = indexArr[it]
            inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_3, indexArr, it )
        else:
            # ref_3 = it
            inst = "{}: {} = {}".format( hex(self.pc), ref_3, it )
        inst_list.append(inst)
        self.pc += 1

        # ref_4 = tgtArr[ref_3]
        ref_4 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_4, tgtArr, ref_3 )
        inst_list.append(inst)
        self.pc += 1

        # ref_5 = ref_4 + ref_2
        ref_5 = self.get_fresh_ref_name()
        inst = "{}: {} = ADD {} {}".format( hex(self.pc), ref_5, ref_4, ref_2 )
        inst_list.append(inst)
        self.pc += 1

        # tgtArr[ref_3] = ref_5
        tmp_6 = self.get_fresh_tmp_name()
        inst = "{}: {} = ARRAY-WRITE {} {} {}".format( hex(self.pc), tmp_6, tgtArr, ref_3, ref_5 )
        inst_list.append(inst)
        self.pc += 1

        if nested and l:
            # self._read_list += [srcArr, srcStart, indexArr, tgtArr]
            # quick-fix <type i>: no need to include srcStart any more as it's processed in const/addc/...
            self._read_list += [srcArr, indexArr, tgtArr]
            self._write_list += [tgtArr]
        elif nested and (not l):
            # self._read_list += [srcArr, srcStart, indexArr, tgtArr]
            # quick-fix <type i>: no need to include srcStart any more as it's processed in const/addc/...
            self._read_list += [srcArr, indexArr, tgtArr]
            self._write_list += [tgtArr]
        elif (not nested) and l:
            # self._read_list += [srcArr, srcStart, tgtArr]
            # quick-fix <type i>: no need to include srcStart any more as it's processed in const/addc/...
            self._read_list += [srcArr, tgtArr]
            self._write_list += [tgtArr]
        else:
            # self._read_list += [srcArr, srcStart, tgtArr]
            # quick-fix <type i>: no need to include srcStart any more as it's processed in const/addc/...
            self._read_list += [srcArr, tgtArr]
            self._write_list += [tgtArr]

        return inst_list

    def eval_INCRANGE(self, node, args):
        return self.build_incrange(node, args, False, False)

    def eval_INCRANGE_L(self, node, args):
        return self.build_incrange(node, args, True, False)

    def eval_NESTED_INCRANGE(self, node, args):
        return self.build_incrange(node, args, False, True)

    def eval_NESTED_INCRANGE_L(self, node, args):
        return self.build_incrange(node, args, True, True)

    def build_map(self, node, args, l):     
        # print("build_map args: {}".format(args))
        # print("build_map l: {}".format(l)) 
        tgtArr = args[0]
        if l:
            srcVal = None
            Lam = args[1]
        else:
            srcVal = args[1]
            Lam = None
        it = self.iterator
        # build_map is doing: 
        # 1 (lambda). tgtArr[it] = Lam( tgtArr[it] )  <-- yes, that's the design
        # 2 ().       tgtArr[it] = srcVal

        inst_list = []

        # e.g., self.iterator = {{GuardStart}}
        inst = "{}: {} = {{GuardStart}}".format(hex(self.pc), it)
        inst_list.append(inst)
        self.pc += 1

        ref_0 = self.get_fresh_ref_name()
        if l:
            # ref_0 = tgtArr[it]
            inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, tgtArr, it )
        else:
            # ref_0 = srcVal
            inst = "{}: {} = {}".format( hex(self.pc), ref_0, srcVal )
        inst_list.append(inst)
        self.pc += 1

        ref_1 = self.get_fresh_ref_name()
        if l:
            # ref_1 = Lam( ref_0 )
            inst = "{}: {} = {}".format( hex(self.pc), ref_1, Lam.replace("__x", ref_0) )
        else:
            # ref_1 = ref_0
            inst = "{}: {} = {}".format( hex(self.pc), ref_1, ref_0 )
        inst_list.append(inst)
        self.pc += 1

        # tgtArr[it] = ref_1
        tmp_1 = self.get_fresh_tmp_name()
        inst = "{}: {} = ARRAY-WRITE {} {} {}".format( hex(self.pc), tmp_1, tgtArr, it, ref_1 )
        inst_list.append(inst)
        self.pc += 1

        if l:
            self._read_list += [tgtArr]
            self._write_list += [tgtArr]
        else:
            self._read_list += [srcVal]
            self._write_list += [tgtArr]

        return inst_list

    def eval_MAP(self, node, args):
        return self.build_map(node, args, False)

    def eval_MAP_L(self, node, args):
        return self.build_map(node, args, True)

    def build_updaterange(self, node, args, l):   
        # print("build_updaterange args: {}".format(args))
        # print("build_updaterange l: {}".format(l))     
        indexArr = args[0]
        tgtArr = args[1]
        if l:
            srcVal = None
            Lam = args[2]
        else:
            srcVal = args[2]
            Lam = None
        it = self.iterator
        # build_updaterange is doing: 
        # 1 (lambda). tgtArr[indexArr[it]] = Lam( tgtArr[indexArr[it]] )
        # 2 (). tgtArr[indexArr[it]] = srcVal

        inst_list = []

        # e.g., self.iterator = {{GuardStart}}
        inst = "{}: {} = {{GuardStart}}".format(hex(self.pc), it)
        inst_list.append(inst)
        self.pc += 1

        # ref_0 = indexArr[it]
        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, indexArr, it )
        inst_list.append(inst)
        self.pc += 1

        ref_1 = self.get_fresh_ref_name()
        if l:
            # ref_1 = tgtArr[ref_0]
            inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_1, tgtArr, ref_0 )
        else:
            # ref_1 = srcVal
            inst = "{}: {} = {}".format( hex(self.pc), ref_1, srcVal )
        inst_list.append(inst)
        self.pc += 1

        ref_2 = self.get_fresh_ref_name()
        if l:
            # ref_2 = Lam( ref_1 )
            inst = "{}: {} = {}".format( hex(self.pc), ref_2, Lam.replace("__x", ref_1) )
        else:
            # ref_2 = ref_1
            inst = "{}: {} = {}".format( hex(self.pc), ref_2, ref_1 )
        inst_list.append(inst)
        self.pc += 1

        # tgtArr[ref_0] = ref_2
        tmp_3 = self.get_fresh_tmp_name()
        inst = "{}: {} = ARRAY-WRITE {} {} {}".format( hex(self.pc), tmp_3, tgtArr, ref_0, ref_2 )
        inst_list.append(inst)
        self.pc += 1

        if l:
            self._read_list += [tgtArr, indexArr]
            self._write_list += [tgtArr]
        else:
            self._read_list += [srcVal, indexArr]
            self._write_list += [tgtArr]

        return inst_list
    
    def eval_UPDATERANGE(self, node, args):
        return self.build_updaterange(node, args, False)

    def eval_UPDATERANGE_L(self, node, args):
        return self.build_updaterange(node, args, True)

    def build_require_ordered(self, node, args, isAscending):
        # print("build_require_ordered args: {}".format(args))
        # print("build_require_ordered isAscending: {}".format(isAscending))    
        srcArr = args[0]
        op = "LT" if isAscending else "GT" 
        it = self.iterator
        # build_require_ordered is doing:
        # 1 (). require(srcArr[it] op srcArr[it+1])

        inst_list = []

        # e.g., self.iterator = {{GuardStart}}
        inst = "{}: {} = {{GuardStart}}".format(hex(self.pc), it)
        inst_list.append(inst)
        self.pc += 1

        # ref_0 = srcArr[it]
        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, srcArr, it )
        inst_list.append(inst)
        self.pc += 1

        # ref_1 = it + 1
        ref_1 = self.get_fresh_ref_name()
        inst = "{}: {} = ADD {} 1".format( hex(self.pc), ref_1, it )
        inst_list.append(inst)
        self.pc += 1

        # ref_2 = srcArr[ref_1]
        ref_2 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_2, srcArr, ref_1 )
        inst_list.append(inst)
        self.pc += 1

        # ref_3 = ref_0 op ref_2
        ref_3 = self.get_fresh_ref_name()
        inst = "{}: {} = {} {} {}".format( hex(self.pc), ref_3, op, ref_0, ref_2 )
        inst_list.append(inst)
        self.pc += 1

        ckpt_4 = self.get_fresh_ckpt_name()
        inst = "{}: {} = REQUIRE {}".format( hex(self.pc), ckpt_4, ref_3 )
        inst_list.append(inst)
        self.pc += 1

        self._read_list += [srcArr]
        self._ckpt_list += [ckpt_4]
        return inst_list
    
    def eval_REQUIRE_ASCENDING(self, node, args):
        return self.build_require_ordered(node, args, True)

    def eval_REQUIRE_DESCENDING(self, node, args):
        return self.build_require_ordered(node, args, False) 

    def eval_REQUIRE(self, node, args):
        # print("eval_REQUIRE args: {}".format(args))
        prev_list = args[0][0]
        expr = args[0][1]

        inst_list = [] + prev_list

        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = {}".format( hex(self.pc), ref_0, expr )
        inst_list.append(inst)
        self.pc += 1

        ckpt_1 = self.get_fresh_ckpt_name()
        inst = "{}: {} = REQUIRE {}".format( hex(self.pc), ckpt_1, ref_0 )
        inst_list.append(inst)
        self.pc += 1

        self._ckpt_list += [ckpt_1]
        return inst_list

    # (notice) currently isReq flag is not used here
    # since we treat `require(transfer())` as `transfer()` in verification
    def build_transfer(self, node, args, l, isReq):
        # print("build_transfer args: {}".format(args))
        # print("build_transfer l: {}".format(l))  
        # print("build_transfer isReq: {}".format(isReq))  
        toAddr = args[0]
        fromArr = args[1]
        Lam = args[2] if l else None
        it = self.iterator
        # build_transfer is doing:
        # 1 (req+lambda)  require( transfer( toAddr[it], Lam( fromArr[it] ) ) )
        # 2 (req only)    require( transfer( toAddr[it], fromArr[it] ) )
        # 3 (lambda only) transfer( toAddr[it], Lam( fromArr[it] ) )
        # 4 ()            transfer( toAddr[it], fromArr[it] )

        inst_list = []

        # e.g., self.iterator = {{GuardStart}}
        inst = "{}: {} = {{GuardStart}}".format(hex(self.pc), it)
        inst_list.append(inst)
        self.pc += 1

        # ref_0 = fromArr[it]
        ref_0 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_0, fromArr, it )
        inst_list.append(inst)
        self.pc += 1

        ref_1 = self.get_fresh_ref_name()
        if l:
            # ref_1 = Lam(ref_0)
            inst = "{}: {} = {}".format( hex(self.pc), ref_1, Lam.replace("__x", ref_0) )
        else:
            # ref_1 = ref_0
            inst = "{}: {} = {}".format( hex(self.pc), ref_1, ref_0 )
        inst_list.append(inst)
        self.pc += 1

        # ref_2 = toAddr[it]
        ref_2 = self.get_fresh_ref_name()
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(self.pc), ref_2, toAddr, it )
        inst_list.append(inst)
        self.pc += 1

        # tnsf_3 = transfer( ref_2, ref_1 )
        tnsf_3 = self.get_fresh_tnsf_name()
        inst = "{}: {} = TRANSFER {} {}".format( hex(self.pc), tnsf_3, ref_2, ref_1 )
        inst_list.append(inst)
        self.pc += 1

        self._read_list += [toAddr, fromArr]
        self._ckpt_list += [tnsf_3]
        # do not have to deal with require here
        return inst_list

    def eval_TRANSFER(self, node, args):
        return self.build_transfer(node, args, False, False)
    
    def eval_TRANSFER_L(self, node, args):
        return self.build_transfer(node, args, True, False)

    def eval_REQUIRE_TRANSFER(self, node, args):
        return self.build_transfer(node, args, False, True)
    
    def eval_REQUIRE_TRANSFER_L(self, node, args):
        return self.build_transfer(node, args, True, True)

    def eval_summarize(self, node, args):
        start = args[1]
        end = args[2]
        body = args[0] # (inst_list, verify_list, read_list, write_list, loop_vars)
        it = self.iterator

        # there's always an end
        # e.g., self.iterator = {{GuardEnd}}
        inst = "{}: {} = {{GuardEnd}}".format(hex(self.pc), it)
        inst_list = body + [inst]
        self.pc += 1

        new_body =[inst.format(GuardStart=start, GuardEnd=end) for inst in inst_list]

        # process the lists and pack here
        def is_var_authentic(vv):
            if vv.startswith("TMP_") or vv.startswith("REF_"):
                return False
            try:
                # FIXME: beware of NaN
                float(vv)
            except ValueError:
                return True
            return False

        # (notice) to align with the SlitherIR wher `_owners.length` in read set is displayed as
        # `_owners` only, this function processes this part *case by case* as needed
        # i.e., "_owners.length" will be mapped to "_owners" only
        def regularize_var_list(vl):
            new_vl = []
            for q in vl:
                tq = q.split(".")
                if len(tq)==2 and tq[1]=="length":
                    new_vl.append(tq[0])
                elif len(tq)==1:
                    new_vl.append(tq[0])
                elif q == 'msg.sender':
                    new_vl.append(q)
                else:
                    raise NotImplementedError("Unsupported member access pattern: {}".format(tq))
            return new_vl
            # return vl

        authentic_read_list = list( set([p for p in regularize_var_list(self._read_list) if is_var_authentic(p)]) )
        authentic_write_list = list( set([p for p in regularize_var_list(self._write_list) if is_var_authentic(p)]) )
        # self._ckpt_list is authentic already
        loop_vars = [self.iterator]
        verify_list = list( set(self._ckpt_list+authentic_write_list) - set(loop_vars) )

        # FIXME: ignoring structs/other_contracts/other_funcs/other_decs
        return new_body, verify_list, authentic_read_list, authentic_write_list, loop_vars

    def eval_summarize_nost(self, node, args):
        end = args[1]
        body = args[0]
        it = self.iterator

        # there's always an end
        # e.g., self.iterator = {{GuardEnd}}
        inst = "{}: {} = {{GuardEnd}}".format(hex(self.pc), it)
        inst_list = body + [inst]
        self.pc += 1

        # (notice) replace GuardStart with self.iterator if it's not initialized
        # should keep i=i
        new_body = [inst.format(GuardStart=it, GuardEnd=end) for inst in inst_list]

        # process the lists and pack here
        def is_var_authentic(vv):
            if vv.startswith("TMP_") or vv.startswith("REF_"):
                return False
            try:
                # FIXME: beware of NaN
                float(vv)
            except ValueError:
                return True
            return False

        # (notice) to align with the SlitherIR wher `_owners.length` in read set is displayed as
        # `_owners` only, this function processes this part *case by case* as needed
        # i.e., "_owners.length" will be mapped to "_owners" only
        def regularize_var_list(vl):
            for q in vl:
                tq = q.split(".")
                if len(tq)==2 and tq[1]=="length":
                    new_vl.append(tq[0])
                elif len(tq)==1:
                    new_vl.append(tq[0])
                else:
                    raise NotImplementedError("Unsupported member access pattern: {}".format(tq))
            return new_vl
            # return vl

        authentic_read_list = list( set([p for p in regularize_var_list(self._read_list) if is_var_authentic(p)]) )
        authentic_write_list = list( set([p for p in regularize_var_list(self._write_list) if is_var_authentic(p)]) )
        # self._ckpt_list is authentic already
        loop_vars = [self.iterator]
        verify_list = list( set(self._ckpt_list+authentic_write_list) - set(loop_vars) )

        # FIXME: ignoring structs/other_contracts/other_funcs/other_decs
        return new_body, verify_list, authentic_read_list, authentic_write_list, loop_vars

    def eval_intFunc(self, node, args):
        return args[0]

    def eval_nonintFunc(self, node, args):
        return args[0]

    def build_seq(self, node, args):
        loop0 = args[0]
        loop1 = args[1]
        return loop0+loop1

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

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--file", help="solidity file path from which to extract a loop", type=str)
    parser.add_argument("--prune", help="Activates analysis-based pruning", action="store_true")
    parser.add_argument("--verbose", help="show more debugging information for developer", action="store_true")
    parser.add_argument("--timeout", help="set the timeout", type=int, default=-1)
    return parser.parse_args()

def extract_contracts(sol_file):
    contracts = ""
    afterLoopVars = False
    with open(sol_file, "r") as f:
        for line in f:
            if afterLoopVars:
                contracts += line
            if "LOOPVARS" in line:
                afterLoopVars = True

    return contracts

def extract_structs(sol_file):
    structs = ""
    with open(sol_file, "r") as f:
        for line in f:
            if "struct " in line:
                structs += line

    return structs

def get_loop_summary(file, prune, timeout, verbose): 
    sol_file = file
    seed = None
    # assert False

    # Get all structs declared
    structs = extract_structs(sol_file)
    # Get all contracts declared
    other_contracts = extract_contracts(sol_file)

    # Run analysis (still use constant extraction when in no-prune mode)
    logger.info('Analyzing Input...')
    deps, refs = analyze(sol_file, "C", "foo()")
    lambdas = analyze_lambdas(sol_file, "C", "foo()")
    req_conds = get_requires_conditions(sol_file)
    logger.info('Analysis Successful!')

    if prune:
        actual_spec, glob_decl, types, i_global, global_vars = instantiate_dsl(sol_file, refs.types, lambdas, req_conds, True)
    else:
        actual_spec, glob_decl, types, i_global, global_vars = instantiate_dsl(sol_file, refs.types, None, None, False)
    
    print(actual_spec)
    # input("SEE THE SPEC ABOVE")

    logger.info('Parsing Spec...')
    spec = S.parse(actual_spec)
    logger.info('Parsing succeeded')

    # # Fetch other contract names
    # slither = Slither(sol_file)
    # other_contracts = list(filter(lambda x: x != 'C', map(str, slither.contracts)))
    
    logger.info('Building synthesizer...')
    decider=BoundedModelCheckerDecider(
        interpreter=SymDiffInterpreter(glob_decl, other_contracts, i_global, global_vars, structs, timeout=timeout), example=sol_file, equal_output=check_eq)

    synthesizer = Synthesizer(
        enumerator=DependencyEnumerator(
            spec, max_depth=6, seed=seed, analysis=deps.dependencies if prune else None, types=types),
        decider=decider)
    synthesizer._decider._verbose = verbose
    logger.info('Synthesizing programs...')
    # input("PRESS TO START")

    partial_summaries = []    
    while True:        
        prog, res = synthesizer.synthesize()
        if prog is not None:
            sumd, left = res
            partial_summaries.append((sumd, prog))            
            if left == []:
                progs = list(map(lambda x: str(x[1]), partial_summaries))
                final_prog = "; ".join(progs)
                logger.info('Solution found: {}'.format(final_prog))
                return final_prog
            logger.info('Partial summary found: {}'.format(prog))
        else:
            logger.info('Solution not found!')
            return None

def main(args):    
    sol_file = args.file
    seed = None
    # assert False

    # Get all structs declared
    structs = extract_structs(sol_file)
    # Get all contracts declared
    other_contracts = extract_contracts(sol_file)

    # Run analysis (still use constant extraction when in no-prune mode)
    logger.info('Analyzing Input...')
    deps, refs = analyze(sol_file, "C", "foo()")
    lambdas = analyze_lambdas(sol_file, "C", "foo()")
    req_conds = get_requires_conditions(sol_file)
    logger.info('Analysis Successful!')

    if args.prune:
        actual_spec, glob_decl, types, i_global, global_vars = instantiate_dsl(sol_file, refs.types, lambdas, req_conds, True)
    else:
        actual_spec, glob_decl, types, i_global, global_vars = instantiate_dsl(sol_file, refs.types, None, None, False)

    print(actual_spec)
    # input("SEE THE SPEC ABOVE")

    logger.info('Parsing Spec...')
    spec = S.parse(actual_spec)
    logger.info('Parsing succeeded')

    # # Fetch other contract names
    # slither = Slither(sol_file)
    # other_contracts = list(filter(lambda x: x != 'C', map(str, slither.contracts)))
    
    logger.info('Building synthesizer...')
    decider=BoundedModelCheckerDecider(
        interpreter=SymDiffInterpreter(glob_decl, other_contracts, i_global, global_vars, structs, timeout=args.timeout), example=sol_file, equal_output=check_eq)

    synthesizer = Synthesizer(
        enumerator=DependencyEnumerator(
            spec, max_depth=6, seed=seed, analysis=deps.dependencies if args.prune else None, types=types),
        decider=decider)
    synthesizer._decider._verbose = args.verbose
    logger.info('Synthesizing programs...')
    # input("PRESS TO START")

    partial_summaries = []    
    while True:        
        prog, res = synthesizer.synthesize()
        if prog is not None:
            sumd, left = res
            partial_summaries.append((sumd, prog))            
            if left == []:
                progs = list(map(lambda x: str(x[1]), partial_summaries))
                final_prog = "; ".join(progs)
                logger.info('Solution found: {}'.format(final_prog))
                return True
            logger.info('Partial summary found: {}'.format(prog))
        else:
            logger.info('Solution not found!')
            return False


if __name__ == '__main__':
    main_start_time = time.time()
    logger.setLevel('DEBUG')
    assert len(argv) > 1
    args = parse_args()    
    main(args)
    logger.info("Total Time: {:.4f}s".format(time.time()-main_start_time))
