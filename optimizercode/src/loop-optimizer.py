import sys
import pprint
import os, fnmatch
import subprocess
import sh
import re

from solidity_parser import parser
from bmcsynthesizer import get_loop_summary

initialSolidityCodeLines = open(sys.argv[1]).readlines()
sourceUnit = parser.parse_file(sys.argv[1], loc=True)
sourceUnitObject = parser.objectify(sourceUnit)
stateVariables = []
fdictionary = {}

def check_if_nested_for(forbody):
    for stmt in forbody: 
        if (stmt['type'] == 'ForStatement'):
            return True 
    return False


def get_foo_and_foo_for(filename):
    solidityLines = open('./src/contractfiles/' + filename).readlines()
    sUnit = parser.parse_file('./src/contractfiles/' + filename, loc=True)
    sUnitObject = parser.objectify(sUnit)
    fstmtcode = ''
    ifstmt = False
    for key in sUnitObject.contracts.keys():
        sIndex = 0
        for index, fname in enumerate(sUnitObject.contracts[key].functions):
            if (fname == 'foo' and  fdictionary[filename.replace('_optimized.sol', '')]['movestatements'] != ''):
                if(fdictionary[filename.replace('_optimized.sol', '')]['type'] == 'if'):
                    ifstmt = True
                    fstmtcode = 'function foo() public {'
                    fstmtcode += fdictionary[filename.replace('_optimized.sol', '')]['movestatements']
                    sIndex = sUnitObject.contracts[key].functions[fname]._node['body']['loc']['start']['line']
                elif(fdictionary[filename.replace('_optimized.sol', '')]['type'] == 'nested_for'):
                    ifstmt = True
                    fstmtcode = 'function foo() public {'
                    fstmtcode += fdictionary[filename.replace('_optimized.sol', '')]['movestatements']
                    sIndex = sUnitObject.contracts[key].functions[fname]._node['body']['loc']['start']['line']
                else:
                    fstmtcode = 'function foo() public {' 
                    fstmtcode += fdictionary[filename.replace('_optimized.sol', '')]['movestatements']
                    sIndex = sUnitObject.contracts[key].functions[fname]._node['body']['loc']['start']['line']
            else: 
                sIndex = sUnitObject.contracts[key].functions[fname]._node['body']['loc']['start']['line'] - 1
            eIndex = sUnitObject.contracts[key].functions[fname]._node['body']['loc']['end']['line']        
            while sIndex < eIndex:
                fstmtcode += solidityLines[sIndex]
                sIndex += 1
    if ifstmt: 
        fstmtcode = fstmtcode.replace('function foo_for', '} \n function foo_for') 
    fstmtcode = fstmtcode.replace('foo', filename.replace('_optimized.sol', '')) 
    return fstmtcode  
            
    

def get_dslfunction(summary): 
    parameters = []
    # summarize(nonintFunc(MAP__uint(Categories, 0)), addc_st(0, 0), addc_end(CategoriesLength, 0))
    if 'nonintFunc(' in summary:
        dslf = summary[len('nonintFunc('):-(len(summary) - summary.index('))') -1)]
        parameters.append(dslf)
        summary = summary[len('nonintFunc(') + len(dslf) + 2:]
    if 'intFunc(' in summary:
        dslf = summary[len('intFunc('):-(len(summary) - summary.index('))') -1)]
        parameters.append(dslf)
        summary = summary[len('intFunc(') + len(dslf) + 2:]
    if ' addc_st(' in summary:
        dslf = summary[len(' addc_st('):-(len(summary) - summary.index(')'))]
        parameters.append(dslf.split(',')[0])
        summary = summary[len(' addc_st(' + dslf + ',') + 2:]
    if 'addc_end(' in summary:
        dslf = summary[len('addc_end('):-(len(summary) - summary.index(')'))]
        parameters.append(dslf.split(',')[0])
    return parameters

# Delete all files in the folder
sh.rm(sh.glob('./src/contractfiles/*'))

# Looping through all contracts
for key in sourceUnitObject.contracts.keys():
    # Load state variables in the contract
    for sv in sourceUnitObject.contracts[key].stateVars.keys():
        stateVariables.append(initialSolidityCodeLines[sourceUnitObject.contracts[key].stateVars[sv]['loc']['start']['line'] - 1])
    
    # Step 1 - Loop  through all functions in the contract
    for index, fname in enumerate(sourceUnitObject.contracts[key].functions):
        # code = "contract C { function foo() {" +  + } } "
        # collect all forstatements in this function
        # TODO:// Need to collect parameters as well 
        for fstmt in sourceUnitObject.contracts[key].functions[fname]._node['body']['statements']:
            fstmtcode = ''
            movestatments = ''
            if(fstmt['type'] == 'ForStatement'):
                # Check if there are any new variables being declared
                # move them out of the loop and continue
                if (check_if_nested_for(fstmt['body']['statements'])):
                    movestatments += initialSolidityCodeLines[fstmt['loc']['start']['line'] - 1]
                    sindex = fstmt['loc']['start']['line']
                    eindex = fstmt['loc']['end']['line'] - 1
                    while sindex < eindex:
                        fstmtcode += initialSolidityCodeLines[sindex]
                        sindex += 1
                    for stmt in fstmt['body']['statements']:
                        if(stmt['type'] != 'ForStatement'):
                            movestatments += initialSolidityCodeLines[stmt['loc']['start']['line'] - 1]
                            fstmtcode = fstmtcode.replace(initialSolidityCodeLines[stmt['loc']['start']['line'] - 1], '')
                    fdictionary[fname] = {'type': 'nested_for',
                    'code':fstmtcode,
                    'movestatements': movestatments, 
                    'start': fstmt['loc']['start']['line'], 
                    'end': fstmt['loc']['end']['line']
                    }
                else: 
                    sindex = fstmt['loc']['start']['line'] - 1
                    eindex = fstmt['loc']['end']['line']
                    while sindex < eindex:
                        fstmtcode += initialSolidityCodeLines[sindex]
                        sindex += 1
                    for stmt in fstmt['body']['statements']:
                        if(stmt['type'] == 'VariableDeclarationStatement'):
                            if('Literal' in stmt['initialValue']['type']):
                                movestatments += initialSolidityCodeLines[stmt['loc']['start']['line'] - 1]
                                fstmtcode = fstmtcode.replace(initialSolidityCodeLines[stmt['loc']['start']['line'] - 1], '')
                            else: 
                                fstmtcode = fstmtcode.replace(initialSolidityCodeLines[stmt['loc']['start']['line'] - 1], '')
                    fdictionary[fname] = {'type': 'for',
                    'code':fstmtcode,
                    'movestatements': movestatments, 
                    'start': fstmt['loc']['start']['line'], 
                    'end': fstmt['loc']['end']['line']
                    }
                
            elif(fstmt['type'] == 'IfStatement'):
                sindex = fstmt['loc']['start']['line'] - 1
                eindex = fstmt['loc']['end']['line'] - 1
                movestatments += initialSolidityCodeLines[sindex]
                sindex += 1
                while sindex < eindex:
                    fstmtcode += initialSolidityCodeLines[sindex]
                    sindex += 1
                fdictionary[fname] = {'type': 'if',
                'code':fstmtcode,
                'movestatements': movestatments, 
                'start': fstmt['loc']['start']['line'], 
                'end': fstmt['loc']['end']['line']
                }
            # Need to handle function that has nested for statements apply loop summary on nested loop instead
                
# Step 2 - Create solidity files for all the for loops in the dictionary 
for key, value in fdictionary.items():
    f = open('./src/contractfiles/'+ key+'.sol', 'w')
    additionalstatevariables = ''
    if (value['type'] == 'for' and value['movestatements'] != ''): 
        additionalstatevariables = value['movestatements']
    f.write("contract C { \n" + ''.join(map(str, stateVariables)) 
    + additionalstatevariables
    + "function foo() public { \n" + value['code'] + "} \n}")
    f.close()

# Step 3 - Loop summary for all the solidity files 
for contract in fnmatch.filter(os.listdir('./src/contractfiles/'), '*.sol'): 
    pprint.pprint(contract)
    loopSummary = get_loop_summary('./src/contractfiles/' + contract, True, 600, False)
    if loopSummary is not None: 
        # Remove summarize from the output before
        f = open('./src/contractfiles/'+ contract[:-4] +'.dsl', 'w')
        # Convert loop summary to DSL statement
        parameters = get_dslfunction(loopSummary[:-1].replace('summarize(', ''))
        # Check which functions is used: UPDATERANGE, SUM
        if 'SUM' in parameters[0]:
            f.write(parameters[0][:-1] + ',' + parameters[1] + ',' + parameters[2] + ')')
        if 'MUL' in parameters[0]:
            f.write(parameters[0][:-1] + ',' + parameters[1] + ',' + parameters[2] + ')')
        if 'SUB' in parameters[0]:
            f.write(parameters[0][:-1] + ',' + parameters[1] + ',' + parameters[2] + ')')
        if 'UPDATERANGE' in parameters[0]:
            parameters[0] = parameters[0].replace('1', 'true')
            parameters[0] = parameters[0].replace('0', 'false')
            f.write('UPDATERANGE(' + parameters[0][parameters[0].index('(') + 1:])
        if 'MAP' in parameters[0]: 
            # Getting map parameters
            target = parameters[0][parameters[0].index('(') + 1:-1].split(',')[0]
            val = parameters[0][parameters[0].index('(') + 1:-1].split(',')[1] 
            f.write('MAP(' + target + ',' + parameters[1] + ',' + parameters[2] + ',' + val +')')
        if 'COPYRANGE' in parameters[0]:
            # check if this is const or addc
            srcObj = parameters[0][parameters[0].index('(') + 1:-1].split(',')[0]
            mapstend = parameters[0][parameters[0].index('(') + 1:-1].split(',')[1] 
            if 'const' in mapstend:
                mapstend = mapstend[mapstend.index('(') + 1:-1]
                tgtObj = parameters[0][parameters[0].index('(') + 1:-1].split(',')[2]
                f.write('COPYRANGE(' + srcObj + ',0,' + mapstend + ',' + tgtObj
                 + ',' + parameters[1] + ',' + parameters[2] + ')')
            if 'addc' in mapstend:
                mapstend = mapstend[mapstend.index('(') + 1:]
                tgtObj = parameters[0][parameters[0].index('(') + 1:-1].split(',')[3]
                f.write('COPYRANGE(' + srcObj + ',0,' + mapstend + ',' + tgtObj
                 + ',' + parameters[1] + ',' + parameters[2] + ')')
        if 'NESTED_INCRANGE' in parameters[0]:
            # check if this is const or addc
            srcObj = parameters[0][parameters[0].index('(') + 1:-1].split(',')[0]
            mapstend = parameters[0][parameters[0].index('(') + 1:-1].split(',')[1] 
            if 'const' in mapstend:
                mapstend = mapstend[mapstend.index('(') + 1:-1]
                tgtObj = parameters[0][parameters[0].index('(') + 1:-1].split(',')[2]
                f.write('COPYRANGE(' + srcObj + ',0,' + mapstend + ',' + tgtObj
                 + ',' + parameters[1] + ',' + parameters[2] + ')')
            if 'addc' in mapstend:
                mapstend = mapstend[mapstend.index('(') + 1:]
                tgtObj = parameters[0][parameters[0].index('(') + 1:-1].split(',')[3]
                f.write('COPYRANGE(' + srcObj + ',0,' + mapstend + ',' + tgtObj
                 + ',' + parameters[1] + ',' + parameters[2] + ')')
        f.close()
        
    else: 
        pprint.pprint(contract + ' has no loop summary')

#Step 4 - Create optimized solidity contract
for dsl in fnmatch.filter(os.listdir('./src/contractfiles/'), '*.dsl'): 
    output = subprocess.getoutput("racket ./src/loopsumoptimized.rkt ./src/contractfiles/" + dsl)
    output = output[output.index('shift/reduce conflicts'):]
    output = output.replace('shift/reduce conflicts', '')
    f = open('./src/contractfiles/' + dsl[:-4] + '_optimized.sol', 'w')
    f.write(output)
    f.close()

#Step 4 - Merge all optimized solidity files
finalsolfunctions = ''
for optsol in fnmatch.filter(os.listdir('./src/contractfiles/'), '*_optimized.sol'): 
    finalsolfunctions += get_foo_and_foo_for(optsol)
f = open('./src/contractfiles/final.sol', 'w')
f.write("contract C { \n" + ''.join(map(str, stateVariables)) + finalsolfunctions +" \n}")
f.close()
        


# see output below