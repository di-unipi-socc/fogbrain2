
import os
import json
import shutil

from utils import *

from builder import builder

from commitsGenerator import *


def execute(commits):
    report = {}
    try:
        prolog = get_new_prolog_instance()
        debug("doing first placement")
        next(prolog.query(f"make,fogBrain('{PATH+commits[0]}',_)."))
        debug("completed first placement")
        for commit in commits:
            debug(f"doing {commit}")
            ans = next(prolog.query(f"make,assessFogBrain('{PATH+commit}', (Inferences1, Placement1, Alloc1), (Inferences2, Placement2, Alloc2))."))
            report[commit] = {"reasoning":{
                "inferences": ans["Inferences1"],
                #"placement": parse(ans["Placement1"]),
                #"alloc": parse(ans["Alloc1"]),
            }}
            report[commit]["placement"] = {
                "inferences": ans["Inferences2"],
                #"placement": parse(ans["Placement2"]),
                #"alloc": parse(ans["Alloc2"]),
            }
    except Exception as e:
        debug(f"exception {e.__class__.__name__} at run {run}")
        report["exception"] = e.__class__.__name__
    
    return report


def do_experiments(nodes, commits):
    debug(f"starting new session [nodes: {nodes} - runs: {1}]")
    report = {}
    report[0] = execute(commits)
    return report
    
def experimentsPhase1_2(commits):
    debug("STARTING PHASE 1&2")
    try:
        os.mkdir(PATH_REPORTS)
    except OSError:
        pass
    
    infrastructures = os.listdir(PATH_INFRA)
    infrastructures.sort()
    
    report = {}
    for infra in infrastructures:
        shutil.copyfile(PATH_INFRA+infra, "./infra.pl")
        report[infra]=do_experiments(infra[:-3],commits)
        
        debug("doing analysis")
        analysis = analyse(report)
        debug("writing analysis")
        with open(PATH_REPORTS+"analysis-phase1-2.txt","w+") as f:
            f.write(json.dumps(analysis))
        debug("store completed")
          
    return report


if __name__ == "__main__":
    import time
    start_time = time.time()
    generate_commits(PATH)
    commits = get_commits(PATH)
    debug("commits generated")
    experimentsPhase1_2(commits)
    debug(f"Ended in {round(time.time() - start_time,2)} seconds")
    
    
    
    
    
    
    



