
import os
import json
import shutil

from utils import *

from builder import builder

from commitsGenerator import *

def do_experiments(runs, nodes):
    debug(f"starting new session [nodes: {nodes} - runs: {runs}]")
    report = {}
    commits = get_commits(PATH)
    
    for run in range(runs):
        report[run] = {"inferences":{
                      }}
                      
        try:
            prolog = get_new_prolog_instance()
            debug("doing first placement")
            next(prolog.query(f"make,fogBrain('{PATH+commits[0]}',P,I).")) # first placement for reasoning
            debug("done first placement")
            for commit in commits:
                debug(f"doing {commit} [reasoning]")
                ans = next(prolog.query(f"make,fogBrain('{PATH+commit}',P,I)."))
                report[run]["inferences"][commit] = {"reasoning":ans["I"]}
                report[run]["inferences"][commit]["Placements"] = {"reasoning":parse(ans["P"])}
                debug(f"completed {commit} [reasoning]")
            
            for commit in commits:
                prolog = get_new_prolog_instance()
                debug(f"doing {commit} [placement]")
                ans = next(prolog.query(f"make,fogBrain('{PATH+commit}',P,I)."))
                report[run]["inferences"][commit]["placement"] = ans["I"]
                report[run]["inferences"][commit]["Placements"]["placement"] = parse(ans["P"])
                debug(f"completed {commit} [placement]")
            
        except Exception as e:
            debug(f"exception {e.__class__.__name__} at run {run}")
            report[run]["excpetion"] = e.__class__.__name__
            
            
        debug(f"completed {(run+1)/runs*100}%")
        
    debug("writing on file")
    with open(PATH_REPORTS+"report-"+str(nodes)+"-"+str(runs)+"-"+datetime.now().strftime('%d-%m-%Y-%H-%M-%S')+".txt","w+") as f:
        f.write(json.dumps(report))
    debug("store completed")
            
    return report
        

def experimentsPhase1(nodes):
    debug("STARTING PHASE 1")
    try:
        os.mkdir(PATH_REPORTS)
    except OSError:
        pass
    report = {}
    builder(nodes)
    debug("infrastructure generated")
    report["phase1-nodes"+str(nodes*5)]=do_experiments(1,nodes)
    
    debug("doing analysis")
    analysis = analyse(report)
    debug("writing analysis")
    with open(PATH_REPORTS+"analysis-phase1.txt","w+") as f:
        f.write(json.dumps(analysis))
    debug("store completed")
          
    return report
    
def experimentsPhase2():
    debug("STARTING PHASE 2")
    try:
        os.mkdir(PATH_REPORTS)
    except OSError:
        pass
    
    infrastructures = os.listdir(PATH_INFRA)
    infrastructures.sort()
    
    report = {}
    for infra in infrastructures:
        shutil.copyfile(PATH_INFRA+infra, "./infra.pl")
        report[infra]=do_experiments(1,infra[:-3])
        
        debug("doing analysis")
        analysis = analyse(report)
        debug("writing analysis")
        with open(PATH_REPORTS+"analysis-phase2.txt","w+") as f:
            f.write(json.dumps(analysis))
        debug("store completed")
          
    return report


if __name__ == "__main__":
    import time
    start_time = time.time()
    generate_commits(PATH)
    debug("commits generated")
    experimentsPhase1(2)
    experimentsPhase2()
    debug(f"Ended in {round(time.time() - start_time,2)} seconds")
    
    
    
    
    
    
    



