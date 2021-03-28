from pyswip.prolog import PrologError
from utils import *

from pyswip import Prolog, Functor, Atom

import math

import json

from commitsGenerator import *

from builder import *

RUNS = 1
EPOCHS = 1
LOWER = 1
UPPER = 12

def execute(prolog, commit, report):
    ans = next(prolog.query(f"make,assessFogBrain('{PATH+commit}', (Inferences1, Placement1, Alloc1), (Inferences2, Placement2, Alloc2))."))

    #ans = next(prolog.query(f"make,assessFogBrain('{PATH+commit}', (Inferences1, Placement1, Alloc1), (Inferences2, Placement2, Alloc2))."))
    #print(f"make,assessFogBrain('{PATH+commit}', (Inferences1, Placement1, Alloc1), (Inferences2, Placement2, Alloc2)).")
    report["reasoning"]["inferences"] += ans["Inferences1"]
    report["placement"]["inferences"] += ans["Inferences2"]
    """
    print(ans["Inferences1"])
    print(parse(ans["Placement1"]))
    print(ans["Inferences2"])
    print(parse(ans["Placement2"]))
    """
    return ans
    

def do_experiments(runs, epochs, nodes, commits):
    report = {}
    for run in range(runs):
        try:
            prolog = get_new_prolog_instance()
            report[run]={}
            debug(f"starting run {run}")
            builder(nodes)
            #infra = generate_graph_infrastructure(nodes,int(math.log2(nodes)))
            #print_graph_infrastructure(infra)
            debug("doing first placement")
            next(prolog.query(f"make,fogBrain('{PATH+commits[0]}',_)."))
            debug("completed first placement")
            for commit in commits:
                debug(f"doing {commit}")
                report[run][commit] = {
                    "reasoning":{
                        "inferences":0
                    },
                    "placement":{
                        "inferences":0
                    },
                }
                for epoch in range(epochs):
                    prolog = get_new_prolog_instance()
                    prolog.consult('infra.pl')
                    execute(prolog, commit, report[run][commit])
        except :
            print("error")

    return report
        

def experimentsPhase3(runs, epochs, lower, upper, commits):
    debug("STARTING PHASE 3")
    try:
        os.mkdir(PATH_REPORTS)
    except OSError:
        pass
    report = {}
    for i in range(lower,upper+1):
        nodes = pow(2,i)
        debug(f"STARTING SESSION {nodes} nodes")
        report[nodes]=do_experiments(runs, epochs, nodes, commits)

        debug("doing analysis")
        analysis = analyse(report)
        debug("writing analysis")
        with open(PATH_REPORTS+"TEMP-"+str(nodes)+"-analysis-phase3-"+datetime.now().strftime('%d-%m-%Y-%H-%M-%S')+".txt","w+") as f:
            f.write(json.dumps(analysis))
        debug("store completed")
        
    debug("doing analysis")
    analysis = analyse(report)
    debug("writing analysis")
    with open(PATH_REPORTS+"analysis-phase3.txt","w+") as f:
        f.write(json.dumps(analysis))
    debug("store completed")
    
    return report

if __name__ == "__main__":
    import time
    start_time = time.time()
    generate_commits(PATH)
    debug("commits generated")
    commits = get_commits(PATH)
    experimentsPhase3(RUNS, EPOCHS, LOWER, UPPER, commits)
    debug(f"Ended in {round(time.time() - start_time,2)} seconds")
    
    
    
    
    
    
    



