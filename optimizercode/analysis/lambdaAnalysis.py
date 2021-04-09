from analysis import Analysis
from enum import Enum

from slither.core.declarations import (Contract, Enum, Function,
                                       SolidityFunction, SolidityVariable,
                                       SolidityVariableComposed, Structure)
from slither.slithir.operations import (Index, OperationWithLValue, InternalCall,
                                        Phi, Condition, Operation, Assignment, Binary, BinaryType)
from slither.slithir.variables import (Constant, LocalIRVariable,
                                       ReferenceVariable, ReferenceVariableSSA,
                                       StateIRVariable, TemporaryVariable,
                                       TemporaryVariableSSA, TupleVariableSSA)
from slither.core.solidity_types.type import Type


class LambdaAnalysis(Analysis):

    exprs = []

    def pprint_refinement(self):
        enums = { 1: "INDEX", 2: "GUARD", 3: "READ", 4: "WRITTEN", 5: "CONSTANT" }
        for e, vrs in self.types.items():
            print("{0}: {1}".format(enums[e], set(map(str, vrs))))

    def get_index(self, ir):
        idx = []
        if isinstance(ir, Index):
            idx += [ir.variable_right]
            pts_to = self.fetch_points_to(ir.variable_right)
            if pts_to: idx += [pts_to]

        return idx
    
    def get_guard(self, ir):
        guard = []
        if isinstance(ir, Condition):
            guard += [ir.value]
        return guard

    def get_write_constant(self, ir):
        written = []
        if isinstance(ir, Assignment):
            written.append(ir.lvalue)            
            lvalue_pts_to = self.fetch_points_to(ir.lvalue)
            if lvalue_pts_to: written.append(lvalue_pts_to)
        return written
 
    def get_read(self, ir):
        read = []
        if isinstance(ir, Condition):
            read += [ir.value]
        return read

    def get_constants(self, ir):
        constants = []
        if isinstance(ir, Constant):
            constants.append(ir)            
        if isinstance(ir, Assignment):
            constants += self.get_constants(ir.rvalue)
        if isinstance(ir, Binary):
            for var in ir.get_variable:
                constants += self.get_constants(var)
        return constants

    def get_expr(self, ir):
        operations = ["+", "*", "<<", ">>", "-", "/", "%", "&", "^", "|", "&&", "||"]
        op = BinaryType.str(ir.type)
        if op in operations:            
            args = ir.get_variable
            args = list(map(lambda x: (isinstance(x, Constant), x), args))
            return (op, args)
        return None
    
    def compute_function(self, function):
        # TODO: HANDLE ANY FUNCTION NAME
        if function.name != "foo":
            return
        
        for n, node in enumerate(function.nodes):
            for i, ir in enumerate(node.irs_ssa):
                # Cuts out the iteration of the loop guard by one
                if not (n == len(function.nodes)-1 and i == len(node.irs_ssa)-1):
                    if isinstance(ir, Binary):
                        expr = self.get_expr(ir)
                        if expr:
                            self.exprs.append(expr)
                # if not isinstance(ir, Phi):
                #     self.types[self.Typ.INDEX] += self.get_index(ir)
                #     self.types[self.Typ.GUARD] += self.get_guard(ir)
                #     self.types[self.Typ.WRITTEN] += self.get_write_constant(ir)
                #     self.types[self.Typ.READ] += self.get_read(ir)
                #     self.types[self.Typ.CONSTANT] += self.get_constants(ir)                    
                    
        self.exprs = self.convert_to_non_ssa(self.exprs)
        for i,expr in enumerate(self.exprs):            
            self.exprs[i]=(expr[0],list(map(lambda x:(x[0] or
                                                      str(x[1]) in list(map(str, function.variables_read)) or
                                                      str(x[1]) in list(map(str, function.variables_written)),
                                                      x[1]), expr[1])))

    def convert_to_non_ssa(self, exprs):
        # Need to create new set() as its changed during iteration
        if isinstance(exprs, list):
            ret = []
            for (op, args) in exprs:
                new_args = []
                for (c, arg) in args:
                    new_arg = "VAR"
                    if not isinstance(arg, ReferenceVariableSSA):
                        new_arg = str(self.convert_variable_to_non_ssa(arg))
                    new_args.append((c, new_arg))
                ret.append((op, new_args))
        elif isinstance(exprs, dict):
            ret = dict()
            for (k, values) in exprs.items():
                ret[k] = list(map(self.convert_variable_to_non_ssa, values))                        

        return ret
        
