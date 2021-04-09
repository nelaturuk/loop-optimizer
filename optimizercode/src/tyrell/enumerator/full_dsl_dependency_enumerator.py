from typing import Set, Optional
from random import Random
from tyrell.enumerator.enumerator import Enumerator
from tyrell import dsl as D
from tyrell import spec as S
from tyrell.enumerator.enumerator_ast import EnumeratorAST

func_deps = {
    "COPYRANGE": {2: [0]},
    "SUM": {0: [0,1]},
    "UPDATERANGE": {1:[4]}, # SHOULD INCLUDE 0?
    "MAP": {0: [3]},
    "INCRANGE": {2: [0]},
    "COPYRANGE_L": {2: [0]},
    "SUM_L": {0: [0,1]},
    "MAP_L": {0: [3]},
    "INCRANGE": {2: [0]},
    "FILTER": {}
}

class DependencyEnumerator(Enumerator):
    _rand: Random
    _max_depth: int
    _builder: D.Builder

    def __init__(self, spec: S.TyrellSpec, max_depth: int, seed: Optional[int]=None,
                 analysis=None, types=None):
        self._rand = Random(seed)
        self._builder = D.Builder(spec)
        if max_depth <= 0:
            raise ValueError(
                'Max depth cannot be non-positive: {}'.format(max_depth))
        self._max_depth = max_depth
        self._analysis = analysis
        self._types = types
        self._progs = []
        self._func_idx = 0
        self._last_conc_args = []
        self._invalid_args = {}

        self._history = []
        self._candidate_num = 0
        self.enum = EnumeratorAST(self._builder.output, func_deps, analysis, self._builder)

    def set_iterators(self, its):
        self.enum.set_iterators(its)

    def get_types(self, val):
        val_types = []
        for typ, vals in self._types.items():
            if val in vals:
                val_types.append(typ)

        return val_types
        
    def check_val_deps(self, val, deps_on, deps_from, args, conc_args):
        # Fetch analysis depends on relationships with val (i.e. val LHS)
        analysis_dep_on = []
        if val in self._analysis:
            analysis_dep_on = self._analysis[val]

        # Fetch analysis depends from relationships with val (i.e. val RHS)          
        analysis_dep_from = []
        for var, deps in self._analysis.items():
            if val in deps:
                analysis_dep_from.append(var)

        # print(val, deps_on, deps_from, args, analysis_dep_on, analysis_dep_from)
                
        # Check both depends on and depends from
        for deps, analysis_deps in zip([deps_on, deps_from], [analysis_dep_on, analysis_dep_from]):
            # Check each production dependency
            for dep in deps:
                if dep >= len(conc_args):
                    dep_typ = str(args[dep])
                    # If there is NOT at least one value which could fill in, reject val
                    if not any(map(lambda x: dep_typ in self.get_types(x),analysis_deps)):
                        return False
                else:
                    dep_name = str(self._builder.make_node(conc_args[dep]))
                    if not dep_name in analysis_deps:
                        return False                        
            
        return True
        
    def find_poss_hole_vals(self, prod, conc_args):
        poss_vals = []

        # Fetch production dependencies
        prod_deps = {}
        if prod.name in func_deps:
            prod_deps = func_deps[prod.name]

        # Iterate through production arguments
        for i,arg in enumerate(prod.rhs):
            # Fetch argument production dependencies
            depends_on = []
            if i in prod_deps:
                depends_on = prod_deps[i]
            depends_from = []
            for idx, deps in prod_deps.items():
                if i in deps:
                    depends_from.append(idx)
            # Get possible argument vars based on types
            values = self._builder.get_productions_with_lhs(arg)
            values = list(filter(lambda x: not x.is_function(), values))
            # Perform check for each variable
            arg_poss_vals = []
            for val in values:
                val = val.rhs[0]
                if self.check_val_deps(val, depends_on, depends_from, prod.rhs):
                    arg_poss_vals.append(val)
            poss_vals.append(arg_poss_vals)
                    
        return poss_vals

    def find_poss_hole_vals2(self, prod, conc_args, idx):
        poss_vals = []

        # Fetch production dependencies
        prod_deps = {}
        if prod.name in func_deps:
            prod_deps = func_deps[prod.name]

        arg = prod.rhs[idx]
            
        # Fetch argument production dependencies
        depends_on = []
        if idx in prod_deps:
            depends_on = prod_deps[idx]
        depends_from = []
        for idx2, deps in prod_deps.items():
            if idx in deps:
                depends_from.append(idx2)
        # Get possible argument vars based on types
        values = self._builder.get_productions_with_lhs(arg)
        values = list(filter(lambda x: not x.is_function(), values))
        # Perform check for each variable
        for val in values:
            val = val.rhs[0]
            if self.check_val_deps(val, depends_on, depends_from, prod.rhs, conc_args):
                poss_vals.append(val)
                    
        return poss_vals

    def _generate_value(self, curr_type: S.Type, depth: int, top_level: bool):        
        # First, get all the relevant function rules for current type
        productions = self._builder.get_productions_with_lhs(curr_type)
        # Split by function productions and value productions
        func_prods = list(filter(lambda x: x.is_function(), productions))
        val_prods = list(filter(lambda x: not x.is_function(), productions))

        # Try value productions first to bias shorter candidates        
        for val in val_prods:            
            candidate = self._builder.make_node(val)
            if not depth in self._history:
                print("VALUE: {0}".format(candidate))
                return candidate, depth+1
            # else:
            #     print("REJECTED VALUE: {0}".format(candidate))

        # # No function can be returned at depth 0
        # if depth == 0:
        #     return None, depth
            
        # Try functions second
        for func in func_prods:
            # Iteratively fill function arguments
            arguments = []
            print("=="*8)
            print(func, depth)
            print("--")
            for arg_typ in func.rhs:
                arg, depth = self._generate_value(arg_typ, depth, False)
                print("TYPE: {0}, VAL: {1}".format(arg_typ, arg))
                if arg == None:
                    return None, depth
                arguments.append(arg)
            # arguments = list(map(lambda x: self._builder.make_node(x), arguments))

            candidate = self._builder.make_node(func, arguments)
            if not depth in self._history:
                return candidate, depth+1
            
        # for func in productions[self._func_idx:]:
        #     if self._last_conc_args != []:
        #         new_conc_args = self._last_conc_args[:-1]
        #         invalid_arg = str(self._builder.make_node(self._last_conc_args[-1]))
        #         idx = len(new_conc_args)
        #         invalid_key = (func, tuple(new_conc_args), idx)
        #         if not invalid_key in self._invalid_args:
        #             self._invalid_args[invalid_key] = []
        #         self._invalid_args[invalid_key].append(invalid_arg)
        #         enum_children = self._generate_children(func, idx, new_conc_args)
        #         if enum_children == None:
        #             self._last_conc_args = new_conc_args
        #             return self._generate_func(curr_type)
        #     else:
        #         enum_children = self._generate_children(func, 0, [])
        #     if enum_children != None:
        #         children = list(map(lambda x: self._builder.make_node(x), enum_children))
        #         self._last_conc_args = enum_children
        #         self._func_idx = productions.index(func)
        #         return self._builder.make_node(func, children)

        return None, depth

    def _generate_children(self, func, idx, conc_args):
        if idx == len(func.rhs):
            return conc_args
        poss_values = self.find_poss_hole_vals2(func,conc_args,idx)
        invalid_key = (func, tuple(conc_args), idx)
        invalid_values = []
        if invalid_key in self._invalid_args:
            invalid_values = self._invalid_args[invalid_key]
        poss_values = list(filter(lambda x: not x in invalid_values, poss_values))
        if [] in poss_values:
            return None
        arg = func.rhs[idx]
        productions = self._builder.get_productions_with_lhs(arg)
        productions = list(filter(lambda x: not x.is_function(), productions))

        productions = list(filter(lambda x: str(self._builder.make_node(x)) in poss_values, productions))

        for pot_arg in productions: 
            children = self._generate_children(func, idx+1, conc_args+[pot_arg])
            if children != None:
                return children
        
        return None
    

    def next(self):
        # prog = self._generate_value(self._builder.output, 0, True)
        # self._history.append(self._candidate_num)
        # print(self._history)
        # print(depth)
        # # while prog == None: #and depth < self._max_depth:
        # #     print(self._history)
        # #     print(depth)
        # #     # Erase top-level history before each new top-level generation
        # #     prog, depth = self._generate_value(self._builder.output, depth, True)
        # #     self._history.append(depth)            
        # #     print(prog)
        # return prog

        # print(self.enum.queue[0])
        cand = self.enum.next_candidate()
        while cand == False:
            cand = self.enum.next_candidate()
        # print(self.enum.queue[0])
        # print("$$$$$"*8)
        # while str(cand) in self._history:
        #     print("REPEATED: {0}".format(cand))
        #     raise Exception()
        #     cand =  self.enum.next_candidate()
            
        # self._history.append(str(cand))
        # print(cand)
        return cand
        
