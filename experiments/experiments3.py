from utils import *

from pyswip import Prolog, Functor, Atom

import math

from commitsGenerator import *

from builder import *

RUNS = 1
EPOCHS = 1
LOWER = 4
UPPER = 4

def execute():
    return {}
    #{commits{commit:{reasoning:{inferences,placemenr}, placement:{inferences, placement}}}

def do_experiments(runs, epochs, nodes):
    report = {}
    for run in range(runs):
        report[run]={}
        debug(f"starting run {run}")
        infra = generate_infrastructure(nodes,int(math.log2(nodes)))
        print_infrastructure(infra,nodes)
        debug("infrastructure generated")
        changes = "inital"
        for epoch in range(epochs):
            report[run][epoch] = {"infra_changes": changes}
            report[run][epoch] = execute()
            infra,changes = change_infrastructure(infra)
            print_infrastructure(infra,nodes)

    return report
        

def experiments(runs, epochs, lower, upper):
    debug("STARTING PHASE 3")
    try:
        os.mkdir(PATH_REPORTS)
    except OSError:
        pass
    report = {}
    for i in range(lower,upper+1):
        nodes = pow(2,i)
        report[nodes]=do_experiments(runs, epochs, nodes)
    """
        debug("doing analysis")
        #analysis = analyse(report)
        debug("writing analysis")
        with open(PATH_REPORTS+"TEMP-"+str(nodes)+"-analysis-phase3-"+datetime.now().strftime('%d-%m-%Y-%H-%M-%S')+".txt","w+") as f:
            f.write(json.dumps(analysis))
        debug("store completed")
        
    debug("doing analysis")
    analysis = analyse(report)
    debug("writing analysis")
    with open(PATH_REPORTS+"analysis-phase3-"+datetime.now().strftime('%d-%m-%Y-%H-%M-%S')+".txt","w+") as f:
        f.write(json.dumps(analysis))
    debug("store completed")
    """
    return report
    

if __name__ == "__main__":
    import time
    start_time = time.time()
    generate_commits(PATH)
    debug("commits generated")
    experiments(RUNS, EPOCHS, LOWER, UPPER)
    debug(f"Ended in {round(time.time() - start_time,2)} seconds")
    
    
    
    
    
    
    



