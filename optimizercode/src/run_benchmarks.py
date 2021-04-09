import os
import demo_dependency_enumerator as dde

BENCHMARK_PATH = os.path.join("/", "Users", "grumpy", "utopia", "LoopSummary", "extractor", "benchmarks")

def main():
    total_files = 0
    succeeded = 0
    failed_to_run = 0
    failed_to_synth = 0
    for fname in os.listdir(BENCHMARK_PATH):
        total_files += 1
        try:
            res = dde.main(os.path.join(BENCHMARK_PATH, fname))
            if res:
                succeeded += 1
            else:
                print("FAILED TO SYNTHESIZE: {0}".format(fname))
                failed_to_synth += 1
        except:
            print("FAILED TO RUN: {0}".format(fname))
            failed_to_run += 1

    print("STATISTICS")
    print("**"*8)
    print("Total Files Run: {0}".format(total_files))
    print("Total Succeeded: {0}".format(succeeded))
    print("Total Failed: {0}".format(failed_to_run+failed_to_synth))
    print("Total Failed To Run: {0}".format(failed_to_run))
    print("Total Failed To Synthesize: {0}".format(failed_to_synth))
    print("**"*8)

main()
