from tyrell import spec as S
import sys

from collections import deque

# sys.setrecursionlimit(1000000)

class EnumeratorAST():

    def __init__(self, typ, func_deps, analysis, builder):
        # self.root_node = Node(productions, builder)
        self.builder = builder
        self.func_deps = func_deps
        self.analysis = analysis
        self.st = None
        self.end = None
        productions = self.builder.get_productions_with_lhs(typ)
        if len(productions) > 0:
            summarize = productions[0]            
            # self.queue = [FunctionNode(summarize, summarize.rhs, [],
            #                            func_deps, analysis, builder)]
            self.queue = deque([FunctionNode(summarize, summarize.rhs, [],
                                       func_deps, analysis, builder)])
        else:
            print("No candidates available!")
            # self.queue = []
            self.queue = deque()

    def set_iterators(self, its):
        self.st = its[0]
        self.end = its[1]

    def next_candidate(self):
        # If we had a finite grammar, we can run out of candidates
        if not self.queue:
            return None

        # Pop first node from queue
        # fnode = self.queue.pop(0)
        fnode = self.queue.popleft()

        # Prune sequential summaries which don't have right iterators
        while fnode.bad_iterators(self.st, self.end):
            # If no more options, back out
            if not self.queue:
                return None
            fnode = self.queue.popleft()            
        
        # If no more non-terminals, return candidate
        if fnode.complete():
            return fnode.build_candidate()

        # Prune partial programs which do not satisy dependencies
        while not fnode.is_legal():
            # If no more options, back out
            if not self.queue:
                return None
            # fnode = self.queue.pop(0)
            fnode = self.queue.popleft()
            
        # Expand first non-terminal in fnode and add to queue
        fnodes = fnode.expand()
        # self.queue += fnodes
        self.queue.extend(fnodes)
        
        # Since we didn't get a concrete candidate, try again
        return False
        # return self.next_candidate()
        # return None

class EnumNode():

    def __init__(self, val, builder):
        self.val = val
        self.builder = builder

    def complete(self):
        return True

    def build_candidate(self):
        return self.builder.make_node(self.val)

    def is_legal(self):
        return True

    def vars_contained(self):
        return [str(self.build_candidate())]
    
    def copy(self):
        return self

    def __str__(self):
        return str(self.val)
    
class FunctionNode():

    def __init__(self, func_prod, arg_types, children, func_deps, analysis, builder):
        self.func_prod = func_prod
        # copy arg_types to avoid aliasing
        self.arg_types = list(arg_types)
        self.children = children
        self.builder = builder
        self.func_deps = func_deps
        self.analysis = analysis
        # self.isFunc = True

    def iterators_compat(self, it, it_sk):
        if it.name != it_sk.func_prod.name:
            # print(it.name, it_sk.func_prod.name)
            return False

        # Check left child
        if len(it_sk.children) >= 1:
            if str(it.args[0]) != str(it_sk.children[0].val.rhs[0]):
                # print(it.args[0])
                # print(it_sk.children[0].val.rhs[0])
                return False
            
        # Check right child
        if len(it_sk.children) >= 2:
            if str(it.args[1]) != str(it_sk.children[1].val.rhs[0]):
                # print(it.args[1])
                # print(it_sk.children[1].val.rhs[0])
                return False
            
        return True
        
    def bad_iterators(self, st, end):
        # Not bad iterators if non declared yet
        if not st:
            return False
        
        # Only summarize should be checked
        if not self.func_prod.name.startswith("summarize"):
            return False

        # Deal with start
        if len(self.children) >= 2:
            if not self.iterators_compat(st, self.children[1]):
                return True

        # Deal with end
        if end != None:
            # Summarize_nost has no end iterator
            if self.func_prod.name == "summarize_nost":
                return True

            if len(self.children) >= 3:
                if not self.iterators_compat(end, self.children[2]):
                    return True            
        
        return False
        
    def vars_contained(self):
        vars_contd = []
        for child in self.children:
            vars_contd += child.vars_contained()
        return vars_contd
        
    def is_legal(self):
        # Always return true if pruning not selected, i.e., analysis is null
        if self.analysis == None:
            return True
        
        # Check if this function satisfies dependency constraints
        if self.func_prod.name in self.func_deps:
            for val_idx, depends_on_idxs in self.func_deps[self.func_prod.name].items():
                # We can only process depends analysis if the lhs is processed
                if len(self.children) > val_idx:
                    val = self.children[val_idx]
                    # Retrieve all variables which compose this element
                    vars_in_val = val.vars_contained()
                    # For each variable, check that it satisfies constraints
                    for var in vars_in_val:
                        if not var in self.analysis:
                            continue
                        # Iterate through each dependency
                        for dependency_idx in depends_on_idxs:
                            # Only check if this child has been created and is complete
                            if len(self.children) > dependency_idx:
                                child = self.children[dependency_idx]
                                if child.complete():
                                    vars_in_child = child.vars_contained()
                                    # Fetch variable dependencies from loop
                                    vars_depd_on = self.analysis[var]
                                    # If none of the vars in child match deps, reject
                                    if not any([v in vars_in_child for v in vars_depd_on]):
                                        return False
                    
            return True

        # Check if all children of this function satisfy dependency constraints
        for child in self.children:
            if not child.is_legal():
                return False

        # If there are no violations of dependency constraints, function is legal
        return True
        
    def complete(self):
        # If all argument types have been expanded
        if self.arg_types == []:
            # A function with its children expanded is complete if
            #  all its children are complete
            return all(map(lambda x: x.complete(), self.children))
            
        return False

    def build_candidate(self):
        built_args = list(map(lambda x: x.build_candidate(),self.children))
        return self.builder.make_node(self.func_prod, built_args)

    def copy(self):
        arg_types = list(self.arg_types)
        children = list(map(lambda c: c.copy() if c != None else None, self.children))

        return FunctionNode(self.func_prod, arg_types, children,
                            self.func_deps, self.analysis, self.builder)
        
    def expand(self):
        # Expand root first if there are remaining args
        if len(self.arg_types) > 0:
            arg_type = self.arg_types.pop(0)
            arg_prods = self.builder.get_productions_with_lhs(arg_type)
            index = len(self.children)
            self.children.append(None)
            expanded_nodes = []
            for arg_prod in arg_prods:
                if arg_prod.is_function():
                    new_node = FunctionNode(arg_prod, arg_prod.rhs, [],
                                            self.func_deps, self.analysis, self.builder)
                else:
                    new_node = EnumNode(arg_prod, self.builder)
                copy_self = self.copy()
                copy_self.children[index] = new_node
                expanded_nodes.append(copy_self)            

            return expanded_nodes

        # If there are children, expand the first one you can
        for i,child in enumerate(self.children):
            if isinstance(child, FunctionNode):
                child_exps = child.expand()
                # If the child was expanded, return a new Function node for each expansion
                if child_exps != []:
                    expanded_nodes = []
                    for child_exp in child_exps:
                        copy_self = self.copy()
                        copy_self.children[i] = child_exp
                        expanded_nodes.append(copy_self)
                    return expanded_nodes
            
        # If no child could be expanded, then no expansions are possible
        return []

    def __str__(self):
        r = "{0}, {1}, {2}\n".format(self.func_prod, len(self.arg_types), len(self.children))
        children_strs = map(str, self.children)
        split_strs = map(lambda s: s.split("\n"), children_strs)        
        add_tab = map(lambda s: map(lambda l: "\t"+l, s), split_strs)
        aggregate = "\n\n".join(map(lambda s: "\n".join(s), add_tab))
        
        return r + "\n" + aggregate + "\n"
        
# class ProductionNode():

#     def __init__(self, non_terms, terms):
#         self.non_terms = non_terms
#         self.terms = terms

#     def build_candidate(self):
#         return None
    
# class Node():

#     def __init__(self, productions, builder):
#         if (len(productions) == 0):
#             raise Exception("No productions given!")

#         self.productions = productions
#         self.builder = builder
#         self.production_index = 0
#         self.candidate = self.build_candidate()
        
#     def build_candidate(self):
#         # Reset children from previous candidate
#         self.children = []

#         # Return None if no more productions to choose from
#         if self.production_index >= len(self.productions):
#             return None

#         # Fetch next production
#         production = self.productions[self.production_index]
        
#         # Just build and return if it's a value
#         if not production.is_function():
#             return self.builder.make_node(production)            

#         # If a function, build each argument node and append to children
#         for arg_typ in production.rhs:
#             arg_node = Node(self.builder.get_productions_with_lhs(arg_typ), self.builder)
#             self.children.append(arg_node)

#         # Return function candidate
#         return self.builder.make_node(production, self.get_children_candidates())

#     def get_candidate(self):
#         return self.candidate

#     def reset(self):
#         self.production_index = 0
#         self.candidate = self.build_candidate()

#     def get_children_candidates(self):
#         return list(map(lambda x: x.get_candidate(), self.children))

#     def next_candidate(self):
#         # Fetch current candidate
#         candidate = self.candidate
#         # Advance current candidate to next option
#         self.advance_candidate()
#         # Return current candidate
#         return candidate
        
#     def advance_candidate(self):        
#         # If current candidate is a value, simply fetch the
#         #   next candidate and build it
#         if self.children == []:
#             # Build next candidate
#             self.production_index += 1
#             self.candidate = self.build_candidate()
#             return
            
#         # Increment first child by one. If it is out of options,
#         #   reset it and go on to next. Continue this until either
#         #   all are out of options, or one arg can be set to the next option
#         index = 0
#         while True:
#             new_child_cand = self.children[index].next_candidate()
#             if new_child_cand != None or index >= len(self.children):
#                 break
#             self.children[index].reset()
#             index += 1

#         # If there were no options, this top level candidate is dead.
#         if self.children[index].get_candidate() == None:
#             # If this is the last candidate, there are no options
#             if self.production_index >= len(self.productions):
#                 return None
#             # Otherwise, build a new candidate
#             self.production_index += 1
#             self.candidate = self.build_candidate()
#             return
            
#         # Update with next iteration of this top-level candidate
#         self.candidate = self.build_candidate()
        
        
