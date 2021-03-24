
import random
import os
import sys

from pyswip import Prolog

from builder import builder

from commitsGenerator import *

from datetime import datetime

PATH = "./experiments/commits/"

def round_robin(ls):
    size = len(ls)
    index = 0
    while True:
        yield ls[index]
        index = (index+1)%size
        
def pick_at_random(ls):
    while True:
        yield random.choice(ls)
        
def get_commits(path):
    commits = os.listdir(path)
    commits.sort()
    return commits

def get_new_prolog_instance():
    prolog = Prolog()
    for p in prolog.query("retract(deployment(_,_,_,_)),fail"):
        pass
    prolog.consult('fogbrain.pl')
    
    return prolog

def generate_commits():
    try:
        os.mkdir(PATH)
    except OSError:
        pass
    
    app = initial_commit()
    add_commit(app, "initial", DIR=PATH)
    
    app.removeService("videoStorage")
    add_commit(app, "removedService", DIR=PATH)

def generate_infrastructure(nodesnumber):
    builder(nodesnumber)
    
def debug(msg):
    print(f"* {msg} ({datetime.now().strftime('%H:%M:%S')})")

def do_experiments(runs, nodes):
    #TODO: check if no placement availbale
    debug(f"starting new session [nodes: {nodes} - runs: {runs}]")
    report = {}
    commits = get_commits(PATH)
    
    generate_infrastructure(nodes)
    debug("infrastructure generated")
    
    for run in range(runs):
        changes = "" #get_infrastructure()
        report[run] = {"infra_changes":changes,
                      "inferences":{
                      }}
        
        prolog = get_new_prolog_instance()
        debug("doing first placement")
        next(prolog.query(f"make,fogBrain('{PATH+commits[0]}',_,I).")) # first placement for reasoning
        debug("done first placement")
        for commit in commits:
            print(f"* doing {commit} [reasoning] ({datetime.now().strftime('%H:%M:%S')})", end="\r")
            ans = next(prolog.query(f"make,fogBrain('{PATH+commit}',P,I)."))
            report[run]["inferences"][commit] = {"reasoning":ans["I"]}
            sys.stdout.write("\033[K")
        
        for commit in commits:
            prolog = get_new_prolog_instance()
            print(f"* doing {commit} [placement] ({datetime.now().strftime('%H:%M:%S')})", end="\r")
            ans = next(prolog.query(f"make,fogBrain('{PATH+commit}',P,I)."))
            report[run]["inferences"][commit]["placement"] = ans["I"]
            sys.stdout.write("\033[K")
            
        debug(f"completed {(run+1)/runs*100}%")
          
            
    return report
    
def analyse(report):
    analysis = {}
    commits = get_commits(PATH)
    for nodes in report:
        analysis[nodes] = {}
        for commit in commits:
            analysis[nodes][commit] = {"placement":[], "reasoning":[]}
        runs = 0
        for run in report[nodes]:
            for commit in report[nodes][run]["inferences"]:
                analysis[nodes][commit]["reasoning"].append(report[nodes][run]["inferences"][commit]["reasoning"])
                
                analysis[nodes][commit]["placement"].append(report[nodes][run]["inferences"][commit]["placement"])
                
        for commit in analysis[nodes]:
            analysis[nodes][commit]["reasoning"] = sum(analysis[nodes][commit]["reasoning"])/len(analysis[nodes][commit]["reasoning"])
            
            analysis[nodes][commit]["placement"] = sum(analysis[nodes][commit]["placement"])/len(analysis[nodes][commit]["placement"])
            
            analysis[nodes][commit]["ratio"] = analysis[nodes][commit]["placement"]/analysis[nodes][commit]["reasoning"]
        
        
    return analysis
        

def experiments(runs, low=4, upper=11):
    report = {}
    for i in range(low,upper+1):
        nodes = pow(2,i)
        report[nodes]=do_experiments(runs,nodes)
    return report

if __name__ == "__main__":
    import time
    start_time = time.time()
    generate_commits()
    debug("commits generated")
    report = experiments(1, upper=5)
    print(analyse(report))
    debug(f"Ended in {round(time.time() - start_time,2)} seconds")
    
    
    
    
    
    
    



