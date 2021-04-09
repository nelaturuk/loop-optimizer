from typing import Set, Optional
from random import Random
from tyrell.enumerator.enumerator import Enumerator
from tyrell import dsl as D
from tyrell import spec as S

func_deps = {
    "COPYRANGE": {2: [0]},
    "SUM": {0: [0,1]},
    "SHIFTLEFT": {0: [0]},
    "UPDATERANGE": {1:[4]}, # SHOULD INCLUDE 0?
    "MAP": {0: [3]},
    "INCRANGE": {2: [0]},
    "MAPLAMBDA": {0: [3]},
    "SUMLAMBDA": {0: [0,1]}
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

    def _generate_func(self, curr_type: S.Type):
        # First, get all the relevant function rules for current type
        productions = self._builder.get_productions_with_lhs(curr_type)
        productions = list(filter(lambda x: x.is_function(), productions))
        
        for func in productions[self._func_idx:]:
            if self._last_conc_args != []:
                new_conc_args = self._last_conc_args[:-1]
                invalid_arg = str(self._builder.make_node(self._last_conc_args[-1]))
                idx = len(new_conc_args)
                invalid_key = (func, tuple(new_conc_args), idx)
                if not invalid_key in self._invalid_args:
                    self._invalid_args[invalid_key] = []
                self._invalid_args[invalid_key].append(invalid_arg)
                enum_children = self._generate_children(func, idx, new_conc_args)
                if enum_children == None:
                    self._last_conc_args = new_conc_args
                    return self._generate_func(curr_type)
            else:
                enum_children = self._generate_children(func, 0, [])
            if enum_children != None:
                children = list(map(lambda x: self._builder.make_node(x), enum_children))
                self._last_conc_args = enum_children
                self._func_idx = productions.index(func)
                return self._builder.make_node(func, children)

        return None

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
    
    def _do_generate(self, curr_type: S.Type, curr_depth: int, force_leaf: bool,
                     poss_values = []):
        # First, get all the relevant production rules for current type
        productions = self._builder.get_productions_with_lhs(curr_type)
        if force_leaf:
            productions = list(
                filter(lambda x: not x.is_function(), productions))
        if len(productions) == 0:
            raise RuntimeError('RandomASTGenerator ran out of productions to try for type {} at depth {}'.format(
                curr_type, curr_depth))

        # Pick a production rule uniformly at random
        prod = self._rand.choice(productions)
        if not prod.is_function():
            # make_node() will produce a leaf node
            node = self._builder.make_node(prod)
            return node
        else:
            poss_values = self.find_poss_hole_vals(prod)

            # children = []
            # for i,x in enumerate(prod.rhs):
            #     child = self._generate(x, curr_depth + 1, poss_values[i])
            #     children.append(child)
            
            # Recursively expand the right-hand-side (generating children first)
            children = [self._generate(x, curr_depth + 1, poss_values[i]) for i,x in enumerate(prod.rhs)]
            # make_node() will produce an internal node
            return self._builder.make_node(prod, children)

    def _generate(self, curr_type: S.Type, curr_depth: int, poss_values = []):
        return self._do_generate(curr_type, curr_depth,
                                 force_leaf=(curr_depth >= self._max_depth - 1),
                                 poss_values=poss_values)

    def next(self):
        # prog = self._generate(self._builder.output, 0)
        prog = self._generate_func(self._builder.output)
        while str(prog) in self._progs:
            prog = self._generate_func(self._builder.output)
        self._progs.append(str(prog))
        return prog
