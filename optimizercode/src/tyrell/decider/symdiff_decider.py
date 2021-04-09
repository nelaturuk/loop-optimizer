from typing import Callable, NamedTuple, List, Any
from tyrell.decider.decider import Decider
from tyrell.interpreter import Interpreter
from tyrell.decider.result import ok, bad


class SymdiffDecider(Decider):
    _interpreter: Interpreter
    _example: None
    _equal_output: Callable[[Any, Any], bool]

    def __init__(self,
                 interpreter: Interpreter,
                 example: Any,
                 equal_output: Callable[[Any, Any], bool] = lambda x, y: x == y):
        self._interpreter = interpreter
        self._example = example
        self._equal_output = equal_output

    @property
    def interpreter(self):
        return self._interpreter

    @property
    def example(self):
        return self._example

    @property
    def equal_output(self):
        return self._equal_output

    def is_equivalent(self, prog):
        '''
        Test the program on all examples provided.
        Return a list of failed examples.
        '''
        candidate_prog = self.interpreter.eval(prog, None)
        # print("current candidate program:-------------")
        # print(candidate_prog)
        # print("target program:", self._example) 
        # print("verifyer: ", self._equal_output)
        candidate_file = open("_candidate.sol", "w")
        candidate_file.write(candidate_prog)
        candidate_file.close()
        # trigger Symdiff
        return self._equal_output("_candidate.sol", self._example)

    def analyze(self, prog):
        '''
        This basic version of analyze() merely interpret the AST and see if it conforms to our examples
        '''
        if self.is_equivalent(prog):
            return ok()
        else:
            return bad()
