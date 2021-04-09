from analysis import Analysis
from enum import Enum
import re

from slither.core.declarations import (Contract, Enum, Function,
                                       SolidityFunction, SolidityVariable,
                                       SolidityVariableComposed, Structure)
from slither.slithir.operations import (Index, OperationWithLValue, InternalCall,
                                        Phi, Condition, Operation, Assignment, Binary)
from slither.slithir.variables import (Constant, LocalIRVariable,
                                       ReferenceVariable, ReferenceVariableSSA,
                                       StateIRVariable, TemporaryVariable,
                                       TemporaryVariableSSA, TupleVariableSSA)
from slither.core.solidity_types.type import Type


class Refinement(Analysis):

    types = {}
    
    class Typ(Enum):
        INDEX = 1
        GUARD = 2
        READ = 3
        WRITTEN = 4
        CONSTANT = 5
        GUARDSTART = 6
        GUARDEND = 7

    def pprint_refinement(self):
        enums = { 1: "INDEX", 2: "GUARD", 3: "READ", 4: "WRITTEN", 5: "CONSTANT", 6: "GUARDSTART", 7: "GUARDEND" }
        for e, vrs in self.types.items():
            print("{0}: {1}".format(enums[e], set(map(str, vrs))))

    def fetch_points_to(self, value):
        if not (isinstance(value, LocalIRVariable) and value.is_storage):
            if isinstance(value, ReferenceVariable):
                return value.points_to
        return None

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

    def extract_guard_end(self, match):
        if match:
            comps = ['<', '>', '<=', '>=']
            for comp in comps:
                if comp in comps:
                    spl = match.split(comp)
                    if len(spl) == 2:
                        # TODO: Make this cleaner / more robust
                        var = spl[1].replace(' ', '')
                        ar_ops = ['+', '-']
                        for op in ar_ops:
                            if op in var:
                                var_spl = var.split(op)
                                lhs = var_spl[0]
                                rhs = var_spl[1]
                                self.types[self.Typ.GUARDEND].append(lhs)
                                self.types[self.Typ.GUARDEND].append(rhs)
                                return
                        self.types[self.Typ.GUARDEND].append(var)                        
        
    def extract_while_loop(self, contents):
        while_loop = r'while\s*\((.*)\)'
        match = re.search(while_loop, contents)
        if match:
            self.extract_guard_end(match.group(1))
                        
    def extract_for_loop(self, contents):
        for_loop = r'for\s*\(([^;]*);([^;]*);([^)]*)\)'
        match = re.search(for_loop, contents)
        if match:
            if match.group(1):
                eq_spl = match.group(1).split("=")
                if len(eq_spl) == 2:
                    self.types[self.Typ.GUARDSTART].append(eq_spl[1].replace(' ', ''))
            self.extract_guard_end(match.group(2))
                    
    def raw_analysis(self):
        # TODO: replace with slithir AST traversing
        self.types[self.Typ.GUARDSTART] = []
        self.types[self.Typ.GUARDEND] = []                
        if self.fname != '':
            with open(self.fname, 'r') as sol_file:
                contents = sol_file.read()
                self.extract_for_loop(contents)
                self.extract_while_loop(contents)
                
    def compute_function(self, function):
        # TODO: HANDLE ANY FUNCTION NAME
        if function.name != "foo":
            return
        
        self.types[self.Typ.INDEX] = []
        self.types[self.Typ.GUARD] = []
        self.types[self.Typ.WRITTEN] = []
        self.types[self.Typ.READ] = []
        self.types[self.Typ.CONSTANT] = []
        
        is_protected = function.is_protected()
        test = 0
        for node in function.nodes:
            for ir in node.irs_ssa:
                if not isinstance(ir, Phi):
                    self.types[self.Typ.INDEX] += self.get_index(ir)
                    self.types[self.Typ.GUARD] += self.get_guard(ir)
                    self.types[self.Typ.WRITTEN] += self.get_write_constant(ir)
                    self.types[self.Typ.READ] += self.get_read(ir)
                    self.types[self.Typ.CONSTANT] += self.get_constants(ir)                    
                    
        self.types = self.convert_to_non_ssa(self.types)
        self.raw_analysis()        

    def convert_to_non_ssa(self, data_depencies):
        # Need to create new set() as its changed during iteration
        ret = dict()
        for (k, values) in data_depencies.items():
            ret[k] = list(map(self.convert_variable_to_non_ssa, values))

        return ret
        
