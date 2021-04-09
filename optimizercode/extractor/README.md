# Loop Extraction

## Dependencies

* Requires both `solc-0.4.X` and `solc-0.5.X`. I was able to install these from source acquired from [here](https://github.com/ethereum/solidity/releases?after=v0.4.26).
* Requires [SIF](https://github.com/chao-peng/SIF). Following the build instructions worked on Mac. Prior to building, copy the file `ASTVisitor.cpp` into `<path_to_SIF>/libSif/` via `cp ASTVisitor.cpp <path_to_SIF>/libSif/`.

## Setup

After installing the dependencies, you will need to update the paths in `extractor.py`. At the top of the file, you will see the following:

```
solc4_command = os.path.join('/', 'usr', 'local', 'bin', 'solc-0.4')
solc5_command = os.path.join('/', 'usr', 'local', 'bin', 'solc-0.5')
sif_command = os.path.join('SIF', 'build', 'sif', 'sif')
null_out = os.path.join('/', 'dev', 'null')
temporary_json = os.path.join('.', 'tmp.json')
temporary_ast = os.path.join('.', 'tmp.ast')
```

* `solc4_command`: path to `solc-0.4.X` executable
* `solc5_command`: path to `solc-0.5.X` executable
* `sif_command`: path to `SIF` executable, which (if you follow the build instructions), will have the path `<path_to_SIF>/build/sif/sif`
* `null_out`: path to output for solc, which I just discard to `/dev/null`. You likely do not need to change this.
* `temporary_json`: where the json file created by solc will be stored. I have it set by default to be a local file called `tmp.json`. You likely do not need to change this.
* `temporary_ast`: where the ast file created by solc will be stored. I have it set by default to be a local file called `tmp.ast`. You likely do not need to change this.

## How to Run

To run the extractor on a single file, run

`python extractor.py --file <path_to_file>`

To run on all files in a folder, run

`python extractor.py --folder <path_to_folder>`

Results will be saved to the `BENCHMARK_OUT_PATH` directory (which will be created if it does not exist). Within this directory, subdirectories with numeric names (`1`, `2`, `3`, etc.) will be made, indicating the number of statements in the loop extracted. For example, if `foo.sol` had one loop with one statement in it, the extracted loop would be saved to `BENCHMARK_OUT_PATH/1/foo_0.sol`.

### Flags

* `--replace_safemath`: When activated, safemath ops (mul, add, sub, div, mod) will be replaced with standard arithmetic ops
* `--add_safemath`: When activated, if contract "Using" SafeMath and SafeMath operations used in loop, import for SafeMath at "./SafeMath" and "Using SafeMath for uint256" added to contract

## NOTES

* Unrecognized classes used in the loop will be replaced with an empty contract of that name in the output

Limitations

Currently, for the following, the loop extractor will not create a compile-able loop extraction:

* Loops which include function calls not from SafeMath (function calls are not inlined)