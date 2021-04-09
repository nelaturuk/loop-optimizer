# loop-optimizer
# Loop optimizations for smart contracts

Based on Gaschecker there are three types of optimizations we can perform on loops. Three catergories identified below with the identified from the same work: 

### Patterns

#### P3: Expensive operations outside loop

- Moving updates to storage variables in a loop to outside of the loop.  

#### P4: Initialization of static variables in the loop

- Moved declarations of static variables which are not modified in the loop to outside of the loop.

#### P5: Repeated computations in a loop

- Move computations that involve storage access to outside the loop if the computation yields the constant result all through the execution of the loop.

### Workflow for Loop Optimization

Below we define the step-by-step approach for loop optimization: 

1. Read complete solidity code from a file. 
2. For each function with a for loop, create a solidity file with contract C and a function foo(). The for loop must be placed in function foo().
3. For each solidity file that was created, call bmc-synthesizer to create loop summary in DSL.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
4. For each loop summary created, use the updated templates for the operations in loop summary and create new solidity files with the optimized for loop code. 
5. Merge all solidity files into one to create a new gas optimized solidity contract with all the new functions in place. 
6. Final step is to confirm using bisimulations to prove the equivalence of the generated solidity code with the original one using solci-verify.

# Loop Summarization for Smart Contracts

### Getting Started

1. Download ([link](https://racket-lang.org/download/)) and install Racket (v7 or later) if you do not already have it installed on your system.
   - Make sure that the Racket binaries are available on your `PATH`.
2. Download ([link](https://github.com/emina/rosette)) and install Rosette.
3. Compile the bounded model checker (in Rosette) into executable:

```bash
cd ./src/rosette
raco exe ./bmc-rosette.rkt
```

4. Then run the loop optimizer synthesizer:

```
python ./src/loop-optimizer.py <path to the solidity file>
```

If successful a contract with gas optimized code will be generated in "./src/contractfiles/" folder. 

### Folders/Files Relevant to Loop Optimizer

#### ./optimizercode/src/loop-optimizer.py - Contains code that implements optimization workflow.
#### ./optimizercode/src/dsl-translate-optimized.rkt - Updated templates for all operations supported by loop summary.
#### ./optimizercode/src/loopsumoptimized.rkt - Loop summary synthesizer that calls the updated dsl-translate-optimized when creating optimized solidity code.
#### ./optimizercode/src/bmcsynthesizer.py - Bounded model checker synthesizer that creates the loop summary for the initial input solidity files with updated operations to support optimizations. 
#### Bisimulation checks for contracts - ./experiments contains sample product contracts for the experiments
