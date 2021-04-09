"""
    Compute the data depenency between all the SSA variables
"""
from slither.core.declarations import (Contract, Enum, Function,
                                       SolidityFunction, SolidityVariable,
                                       SolidityVariableComposed, Structure)
from slither.slithir.operations import (Index, OperationWithLValue, InternalCall,
                                        Phi)
from slither.slithir.variables import (Constant, LocalIRVariable,
                                       ReferenceVariable, ReferenceVariableSSA,
                                       StateIRVariable, TemporaryVariable,
                                       TemporaryVariableSSA, TupleVariableSSA)
from slither.core.solidity_types.type import Type

# import sys
# sys.path.append("../analysis")
from Const import Const

class Analysis():

    KEY_SSA = "DATA_DEPENDENCY_SSA"
    KEY_NON_SSA = "DATA_DEPENDENCY"
    
    # Only for unprotected functions
    KEY_SSA_UNPROTECTED = "DATA_DEPENDENCY_SSA_UNPROTECTED"
    KEY_NON_SSA_UNPROTECTED = "DATA_DEPENDENCY_UNPROTECTED"
    
    KEY_INPUT = "DATA_DEPENDENCY_INPUT"
    KEY_INPUT_SSA = "DATA_DEPENDENCY_INPUT_SSA"

    def compute(self, slither):
        slither.context[KEY_INPUT] = set()
        slither.context[KEY_INPUT_SSA] = set()

        for contract in slither.contracts:
            compute_contract(contract, slither)

    def compute_contract(self, contract, slither, fname=""):
        # if KEY_SSA in contract.context:
        #     return

        self.fname = fname
        contract.context[self.KEY_SSA] = dict()
        contract.context[self.KEY_SSA_UNPROTECTED] = dict()

        for function in contract.all_functions_called:
            deps = self.compute_function(function)

            # if deps:
            #     self.pprint_dependency(function)            
                
            self.propagate_function(contract, function, self.KEY_SSA,
                                    self.KEY_NON_SSA)
            self.propagate_function(contract,
                                    function,
                                    self.KEY_SSA_UNPROTECTED,
                                    self.KEY_NON_SSA_UNPROTECTED)

            if function.visibility in ['public', 'external']:
                [slither.context[self.KEY_INPUT].add(p) for p in function.parameters]
                [slither.context[self.KEY_INPUT_SSA].add(p) for p in function.parameters_ssa]

            # if deps:
            #     for lvalue, rvalues in deps.items():
            #         for rv in rvalues:
            #             if lvalue in function.context[self.KEY_SSA]:
            #                 if rv in function.context[self.KEY_SSA][lvalue]:
            #                     function.context[self.KEY_SSA][lvalue].remove(rv)
            #     function.context[self.KEY_NON_SSA] = self.convert_to_non_ssa(function.context[self.KEY_SSA])

        self.propagate_contract(contract, self.KEY_SSA, self.KEY_NON_SSA)
        self.propagate_contract(contract, self.KEY_SSA_UNPROTECTED, self.KEY_NON_SSA_UNPROTECTED)

    def propagate_function(self, contract, function, context_key, context_key_non_ssa):
        self.transitive_close(function, context_key, context_key_non_ssa)
        # Propage data dependency
        data_depencencies = function.context[context_key]
        
        for (key, values) in data_depencencies.items():
            # print("{0}: {1}".format(key, list(map(str, values))))
            if not key in contract.context[context_key]:
                contract.context[context_key][key] = set(values)
            else:
                contract.context[context_key][key].union(values)

        # print("--"*8)

    def transitive_close(self, context, context_key, context_key_non_ssa):
        # transitive closure
        changed = True
        while changed:
            changed = False
            # Need to create new set() as its changed during iteration
            data_depencencies = {k: set([v for v in values]) for k, values in context.context[context_key].items()}
            for key, items in data_depencencies.items():
                # print("KEY: {0}".format(key))
                for item in items:
                    if item in data_depencencies:
                        # print("\tDEP: {0}".format(item))
                        additional_items = context.context[context_key][item]
                        for additional_item in additional_items:
                            if not additional_item in items and additional_item != key:
                                # print("\t\tADD: {0}".format(additional_item))
                                changed = True
                                context.context[context_key][key].add(additional_item)
        # print("--"*8)
        context.context[context_key_non_ssa] = self.convert_to_non_ssa(context.context[context_key])


    def propagate_contract(self, contract, context_key, context_key_non_ssa):
        self.transitive_close(contract, context_key, context_key_non_ssa)

    def add(self, lvalue, function, ir, is_protected):
        raise Exception("Need to instantiate compute_function!")        

    def compute_function(self, function):
        raise Exception("Need to instantiate compute_function!")

    def convert_variable_to_non_ssa(self, v):
        if isinstance(v, (LocalIRVariable, StateIRVariable, TemporaryVariableSSA, ReferenceVariableSSA, TupleVariableSSA)):
            return v.non_ssa_version
        assert isinstance(v, (Constant, SolidityVariable, Contract, Enum, SolidityFunction, Structure, Function, Type, Const))
        return v

    def convert_to_non_ssa(self, data_depencies):
        # Need to create new set() as its changed during iteration
        ret = dict()
        for (k, values) in data_depencies.items():
            var = self.convert_variable_to_non_ssa(k)
            if not var in ret:
                ret[var] = set()
            ret[var] = ret[var].union(set([self.convert_variable_to_non_ssa(v)
                                           for v in values]))

        return ret
