from analyze import analyze

import unittest
import os

testPath = os.path.join('.', 'tests')
simplePath = os.path.join(testPath, 'simple')
optPath = os.path.join(testPath, 'optimization')

class Regression(unittest.TestCase):

    def compare_opt(self, name, funcname="foo()"):
        noopt_fname = os.path.join(optPath, name, '{0}.sol'.format(name))
        opt_fname = os.path.join(optPath, name, '{0}_optimization.sol'.format(name))
        D_noopt, R_noopt = analyze(noopt_fname, funcname=funcname)        
        D_opt, R_opt = analyze(opt_fname, funcname=funcname)
        self.compare_two_refinement(R_opt, R_noopt)
        self.compare_dependencies(D_noopt.dependencies, D_opt.dependencies)
    
    def compare_two_refinement(self, R1, R2):
        r1 = R1.types
        r2 = R2.types
        self.compare_refinement(R1, r1, r2[R1.Typ.INDEX], r2[R1.Typ.GUARD],
                                r2[R1.Typ.WRITTEN], r2[R1.Typ.READ])
        
    def compare_refinement(self, R, r1, index, guard, written, read):
        self.assertEqual(r1[R.Typ.INDEX], index)
        self.assertEqual(r1[R.Typ.GUARD], guard)
        self.assertEqual(r1[R.Typ.WRITTEN], written)
        self.assertEqual(r1[R.Typ.READ], read)        

    def compare_dependencies(self, d1, d2):
        self.assertEqual(d1, d2)
        
    def test_t1(self):
        fname = os.path.join(simplePath, 't1.sol')
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(), set(), set(), set())
        self.compare_dependencies(D.dependencies, {})
        
    def test_t2(self):
        fname = os.path.join(simplePath, 't2.sol')
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(['i']), set(['i']),
                                set(['a', 'i']), set(['b', 'i']))
        self.compare_dependencies(D.dependencies, {'a': set(['b', 'i']),
                                                   'i': set(['i'])})
        
    def test_t3(self):
        fname = os.path.join(simplePath, 't3.sol')
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(['i']), set(['i']),
                                set(['a', 'i']), set(['a', 'i']))
        self.compare_dependencies(D.dependencies, {'a': set(['a', 'i']),
                                                   'i': set(['i'])})
        
    def test_t4(self):
        fname = os.path.join(simplePath, 't4.sol')
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(['i', 'c']), set(['i']),
                                set(['a', 'i']), set(['b', 'c', 'i']))
        self.compare_dependencies(D.dependencies, {'a': set(['b', 'c', 'i']),
                                                   'i': set(['i'])})
        
    def test_t5(self):
        fname = os.path.join(simplePath, 't5.sol')
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(['i']), set(['i']),
                                set(['s', 'i']), set(['a', 's', 'i']))
        self.compare_dependencies(D.dependencies, {'s': set(['s', 'a', 'i']),
                                                   'i': set(['i'])})
        
    def test_t6(self):
        fname = os.path.join(simplePath, 't6.sol')
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(['b', 'i']), set(['i']),
                                set(['a', 'i']), set(['b', 'i', 'c']))
        self.compare_dependencies(D.dependencies, {'a': set(['c']),
                                                   'i': set(['i'])})
        
    def test_t7(self):
        fname = os.path.join(simplePath, 't7.sol')
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(['i']), set(['i']),
                                set(['a', 'i']), set(['i', 'c']))
        self.compare_dependencies(D.dependencies, {'a': set(['c']),
                                                   'i': set(['i'])})
        
    def test_t8(self):
        fname = os.path.join(simplePath, 't8.sol')
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(['i']), set(['i']),
                                set(['a', 'i']), set(['a', 'i', 'c']))
        self.compare_dependencies(D.dependencies, {'a': set(['c', 'a', 'i']),
                                                   'i': set(['i'])})
        
    def test_t9(self):
        fname = os.path.join(simplePath, 't9.sol')
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(['i']), set(['i']),
                                set(['a', 'i']), set(['a', 'b', 'i']))
        self.compare_dependencies(D.dependencies, {'a': set(['b', 'a', 'i']),
                                                   'i': set(['i'])})
        
    def test_t10(self):
        fname = os.path.join(simplePath, 't10.sol')
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(['i']), set(['i']),
                                set(['a', 'b', 'i']), set(['b', 'c', 'i']))
        self.compare_dependencies(D.dependencies, {'a': set(['b', 'i']),
                                                   'b': set(['c', 'i']),
                                                   'i': set(['i'])})
        
    def test_t11(self):
        fname = os.path.join(simplePath, 't11.sol')
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(['i']), set(['i']),
                                set(['a', 'b', 'i']), set(['b', 'c', 'i']))
        self.compare_dependencies(D.dependencies, {'a': set(['b', 'c', 'i']),
                                                   'b': set(['c', 'i']),
                                                   'i': set(['i'])})
        
    def test_t12(self):
        fname = os.path.join(simplePath, 't12.sol')
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(['i']), set(['i']),
                                set(['a', 'c', 'i']), set(['b', 'a', 'i']))
        self.compare_dependencies(D.dependencies, {'a': set(['b', 'i']),
                                                   'c': set(['a', 'b', 'i']),
                                                   'i': set(['i'])})

    def test_t13(self):
        fname = os.path.join(simplePath, 't13.sol')
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(['i']), set(['i']),
                                set(['a', 'i']), set(['b', 'c', 'i']))
        self.compare_dependencies(D.dependencies, {'a': set(['b', 'c', 'i']),
                                                   'i': set(['i', 'c'])})

    def test_AquaToken(self):
        name = "AquaToken"
        fname = os.path.join(optPath, name, '{0}.sol'.format(name))
        D, R = analyze(fname)
        self.compare_refinement(R, R.types, set(['idx']), set(['idx', 'toRewardIdx']),
                                set(['idx', 'updatedBalance']),
                                set(['idx', 'rewards', 'updatedBalance',
                                     'holding_totalTokens', 'toRewardIdx',
                                     'fromRewardIdx']))
        self.compare_dependencies(D.dependencies,
                                  {'updatedBalance':
                                   set(['rewards', 'updatedBalance', 'idx',
                                        'holding_totalTokens',
                                        'fromRewardIdx']),
                                   'idx':
                                   set(['fromRewardIdx', 'idx'])})

    def test_AquaToken_Opt(self):
        name = "AquaToken"
        self.compare_opt(name)

    def test_Ottolotto(self):
        name = "Ottolotto"
        funcname = "foo(uint256)"
        fname = os.path.join(optPath, name, '{0}.sol'.format(name))
        D, R = analyze(fname, funcname=funcname)
        self.compare_refinement(R, R.types, set(['i', '_game']), set(['i']),
                                set(['jackpot', 'i']),
                                set(['jackpot', 'i', 'weiRaised', '_game',
                                     'percents', 'gameStats']))
        self.compare_dependencies(D.dependencies,
                                  {'jackpot':
                                   set(['i', 'weiRaised', '_game', 'percents',
                                        'jackpot']),
                                   'i': set(['i'])})
    def test_Ottolotto_Opt(self):
        name = "Ottolotto"
        funcname = "foo(uint256)"
        self.compare_opt(name, funcname=funcname)

    def test_aaAltimxToken(self):
        name = "aaAltimxToken"
        funcname = "foo(uint256[])"
        fname = os.path.join(optPath, name, '{0}.sol'.format(name))
        D, R = analyze(fname, funcname=funcname)
        self.compare_refinement(R, R.types, set(['i']), set(['i', '_amountOfLands']),
                                set(['totalAmount', 'i', 'amount']),
                                set(['_amountOfLands', 'Factor', 'amount', 'i',
                                     'totalAmount']))
        self.compare_dependencies(D.dependencies,
                                  {'totalAmount':
                                   set(['totalAmount', 'amount', '_amountOfLands',
                                        'i', 'Factor']),
                                   'amount':
                                   set(['_amountOfLands', 'Factor', 'i']),
                                   'i': set(['i'])})

    def test_aaAltimxToken_Opt(self):
        name = "aaAltimxToken"
        funcname = "foo(uint256[])"
        self.compare_opt(name, funcname=funcname)        
        
        
if __name__ == '__main__':
    unittest.main()
