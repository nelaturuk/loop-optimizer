import os
import time

from typing import Callable, NamedTuple, List, Any
from tyrell.decider.decider import Decider
from tyrell.interpreter import Interpreter
from tyrell.decider.result import ok, bad
from tyrell.logger import get_logger
from slither import Slither

logger = get_logger('tyrell')

# node types
from slither.slithir.operations.assignment import Assignment
from slither.slithir.operations.binary import Binary
from slither.slithir.operations.unary import Unary
from slither.slithir.operations.index import Index
from slither.slithir.operations.condition import Condition
from slither.slithir.operations.solidity_call import SolidityCall
from slither.slithir.operations.internal_call import InternalCall
from slither.slithir.operations.high_level_call import HighLevelCall
from slither.slithir.operations.type_conversion import TypeConversion
from slither.slithir.operations.length import Length
from slither.slithir.operations.delete import Delete
from slither.slithir.operations.send import Send

from slither.slithir.variables.reference import ReferenceVariable
from slither.solc_parsing.variables.state_variable import StateVariableSolc
from slither.solc_parsing.variables.local_variable import LocalVariableSolc
from slither.slithir.variables.temporary import TemporaryVariable

# helper for patch_constant_str_bool
from slither.slithir.variables.constant import Constant

# helper for patch_slither_delete_read
from slither.slithir.utils.utils import is_valid_lvalue

from slither.solc_parsing.cfg.node import NodeSolc


class BoundedModelCheckerDecider(Decider):
    _interpreter: Interpreter
    _example: None
    _equal_output: Callable[[Any, Any], bool]
    _org_contract = None

    def __init__(self,
                 interpreter: Interpreter,
                 example: Any,
                 equal_output: Callable[[Any, Any], bool] = lambda x, y: x == y):
        self._interpreter = interpreter
        self._example = example
        self._equal_output = equal_output
        self._tmp_counter = -1 # temporary variable counter
        self._ref_counter = -1 # reference variable counter
        self._ckpt_counter = -1 # checkpoint variable counter
        self._tnsf_counter = -1 

        # (notice) apply patches to adapt the behavior/outcome
        self.patch_constant_str_bool()
        self.patch_delete_read()
        # (FIXME) node write set patch is not enabled yet
        # will enable it at the very end
        # self.patch_node_var_written()

        self._verbose = False

        # (debug) see what is the source contract first
        # tmp = self.extract_ir_from_source(self._example)
        # print(tmp)
        # input("DOUBLE-CHECK")

    def patch_constant_str_bool(self):
        # this patch update the str value of a bool constant in Slither IR
        # where originally it displays "True" but now "true" ("False" but now "false")
        # which corresponds with the MyIR and synthesizer representation
        # def new_str(self):
        #     if isinstance(self.value,bool):
        #         return str(self.value).lower()
        #     else:
        #         return str(self.value)
        def new_str(self):
            if isinstance(self.value,bool):
                return "1" if self.value else "0"
            else:
                return str(self.value)

        Constant.__str__ = new_str

    def patch_delete_read(self):
        # e.g., delete KYC[_off[i]]
        # read: KYC, _off, (i is loop var)   ---> this patch removes KYC
        # write: KYC
        # this patch modify the read variables returned by a Delete node
        # since a Delete node here is modeled as a direct mapping (`MAP` or `UPDATERANGE`)
        # but a Delete in Slither has side effect of putting the target `KYC` in read set
        # while a `MAP` operation does not, so to keep them consistent, this patch removes the `KYC` from read set
        def new_read(self):
            return []

        Delete.read = property(new_read)

    def patch_node_var_written(self):
        # a local variable should not be tracked and verified
        # e.g., uint256 amount = ((_amountOfLands[i]) * (Factor));
        # otherwise this will result in RW mismatch because local names are not in enum set
        # and there's no way of specifying it
        def new_variables_written(self):
            new_list = [p for p in list(self._vars_written) if not isinstance(p, LocalVariableSolc)]
            return new_list

        NodeSolc.variables_written = property(new_variables_written)


    @property
    def interpreter(self):
        return self._interpreter

    @property
    def example(self):
        return self._example

    @property
    def equal_output(self):
        return self._equal_output

    def get_fresh_ref_name(self):
        self._ref_counter += 1
        # use "DEF" because "REF" is originally used in Slither IR
        return "DEF_{}".format(self._ref_counter)

    def get_fresh_tmp_name(self):
        self._tmp_counter += 1
        # use "DMP" because "TMP" is originally used in Slither IR
        return "DMP_{}".format(self._tmp_counter)

    def get_fresh_ckpt_name(self):
        # (important) _ckpt_counter is local to every parsing
        # so it should be reset to -1 before every parsing
        self._ckpt_counter += 1
        return "CKPT_{}".format(self._ckpt_counter)

    def get_fresh_tnsf_name(self):
        self._tnsf_counter += 1
        return "TNSF_{}".format(self._tnsf_counter)
    
    def get_fresh_send_name(self):
        self._tnsf_counter += 1
        return "SEND_{}".format(self._tnsf_counter)

    def is_equivalent(self, prog, sumd_vars=[]):
        '''
        Test the program on all examples provided.
        Return a list of failed examples.
        '''
        cand_contract = self.interpreter.eval(prog, None)
        if self._verbose:
            print("#### candidate contract ####")
            print(cand_contract)
        if not self._org_contract:
            print('source contract is empty')
            inst_list, verify_list, read_list, write_list, loop_vars = self.extract_ir_from_source(self._example)
            self._org_contract = (inst_list, verify_list, read_list, write_list, loop_vars)

        if self._verbose:
            print("#### source contract ####")
            print(self._org_contract)
        # trigger Bounded Model Checker
        return self._equal_output(cand_contract, self._org_contract, self._verbose, sumd_vars)

    def analyze(self, prog, sumd_vars=[]):
        '''
        This basic version of analyze() merely interpret the AST and see if it conforms to our examples
        '''
        # if self.is_equivalent(prog):
        #     return ok()
        # else:
        #     return bad()
        return self.is_equivalent(prog, sumd_vars)
        
    def assemble_arrayread(self, curr_addr, ir):
        inst = "{}: {} = ARRAY-READ {} {}".format( hex(curr_addr), ir.lvalue, ir.variable_left, ir.variable_right )
        return curr_addr+1, [inst], [], [ str(ir.lvalue), str(ir.variable_left), str(ir.variable_right) ]

    def assemble_arraywrite(self, curr_addr, ir0, ir1):
        # ir0: Index, ir1: Assignment/Binary
        assert ir0.lvalue == ir1.lvalue
        if isinstance(ir1, Assignment):
            tmp_0 = self.get_fresh_tmp_name()
            inst = "{}: {} = ARRAY-WRITE {} {} {}".format( hex(curr_addr), tmp_0, ir0.variable_left, ir0.variable_right, ir1.rvalue )
            return curr_addr+1, [inst], [], [ str(ir0.variable_left), str(ir0.variable_right), str(ir1.rvalue) ]
        elif isinstance(ir1, Binary):
            # for the Binary, you need one additional var to store the RHS result

            # process the binary part
            code_type = ir1.type_str
            code_dict = {
                "+":"ADD", "-":"SUB", "*":"MUL", "/":"DIV",
                "<":"LT", "<=":"LTE", ">":"GT", ">=":"GTE",
                "==":"EQ", "!=":"NEQ",
            }
            if code_type in code_dict.keys():
                opcode = code_dict[code_type]
            else:
                raise NotImplementedError("Unsupported binary code type: {}".format(code_type))
            ref_0 = self.get_fresh_ref_name()
            inst_0 = "{}: {} = {} {} {}".format( hex(curr_addr), ref_0, opcode, ir1.variable_left, ir1.variable_right )

            # process the array-write part
            tmp_1 = self.get_fresh_tmp_name()
            inst_1 = "{}: {} = ARRAY-WRITE {} {} {}".format( hex(curr_addr+1), tmp_1, ir0.variable_left, ir0.variable_right, ref_0 )

            return curr_addr+2, [inst_0, inst_1], [], [ str(ir0.variable_left), str(ir0.variable_right), str(ir1.variable_left), str(ir1.variable_right) ]
        elif isinstance(ir1, Unary):
            code_type = ir1.type_str
            code_dict = {"!":"NOT"}
            if code_type in code_dict.keys():
                opcode = code_dict[code_type]
            else:
                raise NotImplementedError("Unsupported unary code type: {}".format(code_type))
            ref_0 = self.get_fresh_ref_name()
            inst_0 = "{}: {} = {} {}".format( hex(curr_addr), ref_0, opcode, ir1.rvalue )

            # process the array-write part
            tmp_1 = self.get_fresh_tmp_name()
            inst_1 = "{}: {} = ARRAY-WRITE {} {} {}".format( hex(curr_addr+1), tmp_1, ir0.variable_left, ir0.variable_right, ref_0 )

            return curr_addr+2, [inst_0, inst_1], [], [ str(ir0.variable_left), str(ir0.variable_right), str(ir1.rvalue) ]
        else:
            raise NotImplementedError("Unsupported ARRAY-WRITE original: {}".format(type(ir1)))

    def assemble_delete(self, curr_addr, ir0, ir1):
        # ir0: Index, ir1: Delete
        assert ir0.lvalue == ir1.variable
        tmp_0 = self.get_fresh_tmp_name()
        inst = "{}: {} = ARRAY-WRITE {} {} {}".format( hex(curr_addr), tmp_0, ir0.variable_left, ir0.variable_right, 0 )
        return curr_addr+1, [inst], [], [ str(ir0.variable_left), str(ir0.variable_right) ]

    def assemble_assignment(self, curr_addr, ir):
        inst = "{}: {} = {}".format( hex(curr_addr), ir.lvalue, ir.rvalue )
        return curr_addr+1, [inst], [], [ str(ir.lvalue), str(ir.rvalue) ]

    def assemble_binary(self, curr_addr, ir):
        # (notice) this binary only write to non-ref var
        # i.e., ir.lvalue is not in ivar_dict
        code_type = ir.type_str
        code_dict = {
            "+":"ADD", "-":"SUB", "*":"MUL", "/":"DIV",
            "<":"LT", "<=":"LTE", ">":"GT", ">=":"GTE",
            "==":"EQ", "!=":"NEQ", 
        }
        if code_type in code_dict.keys():
            opcode = code_dict[code_type]
        else:
            raise NotImplementedError("Unsupported binary code type: {}".format(code_type))
        inst = "{}: {} = {} {} {}".format( hex(curr_addr), ir.lvalue, opcode, ir.variable_left, ir.variable_right )
        # (notice) it's impossible to have a reference variable here as an element in write_list, 
        # since that will be processed by array-write, not here
        return curr_addr+1, [inst], [], [ str(ir.lvalue), str(ir.variable_left), str(ir.variable_right) ]

    def assemble_unary(self, curr_addr, ir):
        code_type = ir.type_str
        code_dict = {"!":"NOT"}
        if code_type in code_dict.keys():
            opcode = code_dict[code_type]
        else:
            raise NotImplementedError("Unsupported unary code type: {}".format(code_type))
        inst = "{}: {} = {} {}".format( hex(curr_addr), ir.lvalue, opcode, ir.rvalue )
        return curr_addr+1, [inst], [], [ str(ir.lvalue), str(ir.rvalue) ]

    def assemble_require(self, curr_addr, ir):
        ckpt_0 = self.get_fresh_ckpt_name()
        inst = "{}: {} = REQUIRE {}".format( hex(curr_addr), ckpt_0, ir.arguments[0] )
        return curr_addr+1, [inst], [ckpt_0], [ str(ir.arguments[0]) ]

    # (assumption) transfer result will never be used
    # if it's used, it can only be in require(transfer()), which becomes transfer() only
    # and the result is actually not used
    def assemble_transfer(self, curr_addr, ir):
        tnsf_0 = self.get_fresh_tnsf_name()
        inst = "{}: {} = TRANSFER {} {}".format( hex(curr_addr), tnsf_0, ir.arguments[0], ir.arguments[1] )
        return curr_addr+1, [inst], [tnsf_0], [ str(ir.arguments[0]), str(ir.arguments[1]) ]
    
    def assemble_send(self, curr_addr, ir):
        tnsf_0 = self.get_fresh_send_name()
        inst = "{}: {} = SEND".format( hex(curr_addr), tnsf_0)
        return curr_addr+1, [inst], [tnsf_0], [ ]

    def assemble_address(self, curr_addr, ir):
        inst = "{}: {} = {}".format( hex(curr_addr), ir.lvalue, ir.variable )
        return curr_addr+1, [inst], [], [ str(ir.lvalue), str(ir.variable) ]

    # (notice) all unknown type conversion will be processed here
    # and should log a info
    def assemble_type_conversion(self, curr_addr, ir):
        inst = "{}: {} = {}".format( hex(curr_addr), ir.lvalue, ir.variable )
        return curr_addr+1, [inst], [], [ str(ir.lvalue), str(ir.variable) ]

    # for length attribute, we treat ref.length as a valid token in RosetteIR and model it separately as a symbolic var
    # this matches the enum set
    # FIXME: is this sound? check back later.
    def assemble_length(self, curr_addr, ir):
        # get the true ref name
        ref_name = ir.lvalue.points_to.name
        sym_name = "{}.length".format(ref_name)
        inst = "{}: {} = {}".format( hex(curr_addr), ir.lvalue, sym_name )
        # return curr_addr+1, [inst], [], [ sym_name ]
        return curr_addr+1, [inst], [], [ str(ref_name) ]
        # (important) see the comments in `regularize_var_list`

    # returns: next_addr, inst_list, checkpoint_list
    # checkpoint variable is additional value to verify (currently from `require`)
    # (notice) the checkpoint variable here is modified to the form "CKPT_?" to match the synthesizer
    # assuming that they won't be used anymore (written but not read in the future)
    def get_inst_list_by_irs(self, curr_addr, raw_irs):
        seq_irs = tuple([type(p) for p in raw_irs])

        # (notice) currently skipping conditions
        if Condition in seq_irs:
            return curr_addr, [], [], []

        # detect for potential array-write operations
        ivar_dict = {} # variables generated by Index (LHS of Index)
        tvar_dict = {} # variables generated by InternalCall (LHS / bool of InternalCall / transfer)
        # (notice) the keys of the above two dicts are slither objects, not str

        next_addr = curr_addr
        final_inst_list = []
        final_ckpt_list = [] # (important) this list is actually for both ckpt and tnsf
        final_vars_list = []
        for i in range(len(seq_irs)):
            if seq_irs[i] == Index:
                # LHS is a reference var in the Slither IR
                ivar = raw_irs[i].lvalue
                ivar_dict[ivar] = i # record the LHS
                # then do normal array-read
                next_addr, inst_list, ckpt_list, vars_list = self.assemble_arrayread( next_addr, raw_irs[i] )
            elif seq_irs[i] == Assignment:
                ivar = raw_irs[i].lvalue
                if ivar in ivar_dict.keys():
                    # array-write
                    j = ivar_dict[ivar]
                    next_addr, inst_list, ckpt_list, vars_list = self.assemble_arraywrite( next_addr, raw_irs[j], raw_irs[i] )
                else:
                    # normal assignment
                    next_addr, inst_list, ckpt_list, vars_list = self.assemble_assignment( next_addr, raw_irs[i] )
            elif seq_irs[i] == Binary:
                ivar = raw_irs[i].lvalue
                if ivar in ivar_dict.keys():
                    # array-write
                    j = ivar_dict[ivar]
                    next_addr, inst_list, ckpt_list, vars_list = self.assemble_arraywrite( next_addr, raw_irs[j], raw_irs[i] )
                else:
                    # normal binary
                    next_addr, inst_list, ckpt_list, vars_list = self.assemble_binary( next_addr, raw_irs[i] )
            elif seq_irs[i] == Unary:
                ivar = raw_irs[i].lvalue
                if ivar in ivar_dict.keys():
                    # array-write
                    j = ivar_dict[ivar]
                    next_addr, inst_list, ckpt_list, vars_list = self.assemble_arraywrite( next_addr, raw_irs[j], raw_irs[i] )
                else:
                    # normal unary
                    next_addr, inst_list, ckpt_list, vars_list = self.assemble_unary( next_addr, raw_irs[i] )
            elif seq_irs[i] == SolidityCall:
                fname = raw_irs[i].function.full_name
                if "require" in fname:
                    # (special) Did you use a tvar in your RHS?
                    svar = raw_irs[i].arguments[0]
                    if svar in tvar_dict.keys():
                        # yes I did: skip this require
                        # since this match the require(transfer()) pattern
                        next_addr, inst_list, ckpt_list, vars_list = (next_addr, [], [], [])
                        pass
                    else:
                        # no I didn't: proceed to normal require process
                        next_addr, inst_list, ckpt_list, vars_list = self.assemble_require( next_addr, raw_irs[i] )
                else:
                    raise NotImplementedError("Unsupported solidity call: {}".format(fname))
            elif seq_irs[i] == TypeConversion:
                tname = raw_irs[i].type.name
                if "address" in tname:
                    next_addr, inst_list, ckpt_list, vars_list = self.assemble_address( next_addr, raw_irs[i] )
                else:
                    logger.info("BMC Decider: unknown type conversion encountered, got {}, perform forced (default) conversion.".format(tname))
                    next_addr, inst_list, ckpt_list, vars_list = self.assemble_type_conversion( next_addr, raw_irs[i] )
                    # raise NotImplementedError("Unsupported type conversion: {}".format(tname))
            elif seq_irs[i] == InternalCall:
                fname = raw_irs[i].function.full_name
                if "transfer" in fname:
                    # LHS is a transfer var
                    tvar = raw_irs[i].lvalue
                    tvar_dict[tvar] = i
                    # proceed to normal transfer process
                    next_addr, inst_list, ckpt_list, vars_list = self.assemble_transfer( next_addr, raw_irs[i] )
                else:
                    raise NotImplementedError("Unsupported internal call: {}".format(fname))
            elif seq_irs[i] == Send:
                # LHS is a transfer var
                tvar = raw_irs[i].lvalue
                tvar_dict[tvar] = i
                # proceed to normal transfer process
                next_addr, inst_list, ckpt_list, vars_list = self.assemble_send( next_addr, raw_irs[i] )
            elif seq_irs[i] == HighLevelCall:
                # e.g., token.transfer(participants[i], _amount);
                # (CLARIFY-ME) not sure this is actually the same to `transfer` in InternalCall or not
                # but it currently behaves like `transfer`
                fname = raw_irs[i].function.full_name
                if "transfer" in fname:
                    # follow the `transfer` routine
                    tvar = raw_irs[i].lvalue
                    tvar_dict[tvar] = i
                    next_addr, inst_list, ckpt_list, vars_list = self.assemble_transfer( next_addr, raw_irs[i] )
                else:
                    raise NotImplementedError("Unsupported high level call: {}".format(fname))
            elif seq_irs[i] == Length:
                # e.g., balances[_owners[i]] = ((totalSupply) / (_owners.length));
                # FIXME: only work with ref.length, for those ref[ind].length, since they don't fall into any valid type
                # we aren't solving them anyway, they will raise exception
                next_addr, inst_list, ckpt_list, vars_list = self.assemble_length( next_addr, raw_irs[i] )
            elif seq_irs[i] == Delete:
                # e.g., `delete KYC[_off[i]]` should be modeled as `KYC[_off[i]] = 0`, similar to map
                # here follows the Assignment procedure
                ivar = raw_irs[i].variable
                if ivar in ivar_dict.keys():
                    # most likely delete an array element
                    j = ivar_dict[ivar]
                    next_addr, inst_list, ckpt_list, vars_list = self.assemble_delete( next_addr, raw_irs[j], raw_irs[i] )
                else:
                    # can this happen? most likely delete a var
                    raise NotImplementedError("Unsupported delete: trying to delete a non-ref var.")
            else:
                raise NotImplementedError("Unsupported instruction type: {}".format(seq_irs[i]))

            final_inst_list += inst_list
            final_ckpt_list += ckpt_list
            final_vars_list += vars_list

        return next_addr, final_inst_list, final_ckpt_list, final_vars_list

    def source_code_preprocess(self, target_contract):
        # assume that there's no expression spanning across multiple lines
        with open(target_contract, "r", encoding="iso-8859-1") as f:
            raw_lines = f.readlines()
        processed_lines = []
        for dline in raw_lines:
            rline = dline.strip().replace(" ","")
            # FIXME: a crappy matching
            if rline.startswith("require("):
                r1 = len("require(")
                r2 = rline.find(");")
                rcond = rline[r1:r2]
                rclist = rcond.split("&&")
                for rc in rclist:
                    processed_lines.append("require({});\n".format(rc))
            else:
                processed_lines.append(dline)

        
        rtime = time.time()
        rname = os.path.basename(target_contract)
        rpath = os.path.dirname(target_contract)
        ppath = os.path.dirname(os.path.dirname(target_contract))
        
        # FIXME: this creates tmp folder at ase_benchmarks_regularized/ or src/
        if not os.path.isdir(os.path.join(ppath,"tmp")):
            os.mkdir(os.path.join(ppath,"tmp"))
        new_path = os.path.join(ppath,"tmp","{}.{}".format(rtime,rname))
        with open(new_path, "w", encoding="iso-8859-1") as f:
            f.write("".join(processed_lines))

        return new_path


    def extract_ir_from_source(self, target_contract):
        processed_target_contract = self.source_code_preprocess(target_contract)
        # slither = Slither(target_contract)
        slither = Slither(processed_target_contract)

        contract = slither.contracts[0]
        function = contract.functions_declared[0]
        (_, _, _, func_summaries, _) = contract.get_summary()
        (_, _, _, _, read_list, write_list, _, _) = func_summaries[0]

        # print("# original read: {}".format(read_list))
        # print("# original write: {}".format(write_list))
        # input("PAUSE-TO-CHECK")

        address = 0
        inst_list = []
        ckpt_list = []
        vars_list = []
        
        self._ckpt_counter = -1 # reset _ckpt_counter
        self._tnsf_counter = -1 # reset _tnsf_counter

        for node in function.nodes:

            if len(node.irs)>0:
                address, tmp_inst_list, tmp_ckpt_list, tmp_vars_list = self.get_inst_list_by_irs(address, node.irs)
                inst_list += tmp_inst_list
                ckpt_list += tmp_ckpt_list
                vars_list += tmp_vars_list

        def is_var_authentic(vv):
            if vv.startswith("TMP_") or vv.startswith("REF_"):
                return False
            try:
                # FIXME: beware of NaN
                float(vv)
            except ValueError:
                return True
            return False
        # clear the vars_list
        authentic_vars_list = [p for p in vars_list if is_var_authentic(p)]
        authentic_read_list = read_list
        authentic_write_list = write_list
        loop_vars = list( set(authentic_vars_list) - set(authentic_read_list) - set(authentic_write_list) )
        assert len(loop_vars) <= 1, "Assertion Error: Length of loop_vars > 1, got: {}".format(loop_vars)

        verify_list = list( set(ckpt_list+authentic_write_list) - set(loop_vars) )

        return inst_list, verify_list, authentic_read_list, authentic_write_list, loop_vars
