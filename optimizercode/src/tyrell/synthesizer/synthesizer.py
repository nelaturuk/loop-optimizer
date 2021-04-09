from abc import ABC, abstractmethod
from typing import Any
import re

from tyrell.interpreter import InterpreterError
from tyrell.enumerator import Enumerator
from tyrell.decider import Decider
from tyrell.dsl import Node
from tyrell.logger import get_logger

logger = get_logger('tyrell.synthesizer')


class Synthesizer(ABC):

    _enumerator: Enumerator
    _decider: Decider

    def __init__(self, enumerator: Enumerator, decider: Decider):
        self._enumerator = enumerator
        self._decider = decider
        self.partial_summaries = []
        self.sumd_vars = []
        
    @property
    def enumerator(self):
        return self._enumerator

    @property
    def decider(self):
        return self._decider

    def get_iterator(self, name, prog):
        matches = re.findall(r"({0}\([^)]*\))".format(name), prog)
        if matches != []:
            return matches[0]

        return None
    
    def get_iterators(self, prog):
        # for st in ["addc_st", "subc_st"]:
        #     st_it = self.get_iterator(st, prog)
        #     if st_it: break

        # for end in ["addc_end", "subc_end"]:
        #     end_it = self.get_iterator(end, prog)
        #     if end_it: break

        # if (st_it and not end_it) or (end_it and not st_it):
        #     raise Exception("Only one iterator fetched!")

        # return st_it, end_it

        name = prog.name

        if not name.startswith("summarize"):
            raise Exception("{0} is not summarize!".format(name))

        st_it = prog.args[1]
        
        if name == "summarize":
            end_it = prog.args[2]
        else:
            end_it = None
            
        return st_it, end_it
            
    def synthesize(self):
        '''
        A convenient method to enumerate ASTs until the result passes the analysis.
        Returns the synthesized program, or `None` if the synthesis failed.
        '''
        num_attempts = 0
        prog = self._enumerator.next()
        while prog is not None and not str(prog) in self.partial_summaries:
            num_attempts += 1
            logger.debug('Enumerator generated: {}'.format(prog))
            # print('Enumerator generated: {}'.format(prog))
            try:
                res = self._decider.analyze(prog, self.sumd_vars)
                if res == False:
                    # info = res.why()
                    info = "None"
                    logger.debug('Program rejected. Reason: {}'.format(info))
                    self._enumerator.update(info)
                    prog = self._enumerator.next()
                else:                    
                    logger.debug(
                        'Program accepted after {} attempts'.format(num_attempts))
                    self.partial_summaries.append(str(prog))
                    self.sumd_vars.append(res[0])
                    self._enumerator.set_iterators(self.get_iterators(prog))
                    return (prog, res)
            except InterpreterError as e:
                info = self._decider.analyze_interpreter_error(e)
                logger.debug('Interpreter failed. Reason: {}'.format(info))
                self._enumerator.update(info)
                prog = self._enumerator.next()
        logger.debug(
            'Enumerator is exhausted after {} attempts'.format(num_attempts))
        return (None, None)
