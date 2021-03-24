
import random
import os

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
    debug(f"starting new session [nodes: {nodes} - runs: {runs}]")
    report = {}
    commits = get_commits(PATH)
    
    generate_infrastructure(nodes)
    debug("infrastructure generated")
    
    for run in range(runs):
        changes = "" #get_infrastructure()
        report[run] = {"infra_changes":changes,
                      "inferences":{
                          "placement":{},
                          "reasoning":{},
                      }}
        
        prolog = get_new_prolog_instance()
        next(prolog.query(f"make,fogBrain('{PATH+commits[0]}',_,I).")) # first placement for reasoning
        for commit in commits:
            ans = next(prolog.query(f"make,fogBrain('{PATH+commit}',P,I)."))
            report[run]["inferences"]["reasoning"][commit] = ans["I"]
        
        for commit in commits:
            prolog = get_new_prolog_instance()
            ans = next(prolog.query(f"make,fogBrain('{PATH+commit}',P,I)."))
            report[run]["inferences"]["placement"][commit] = ans["I"]
        
        print(f"* completed {round((run+1)/runs*100,2)}% ({datetime.now().strftime('%H:%M:%S')})", end="\r")
            
    print(f"* completed 100% ({datetime.now().strftime('%H:%M:%S')})   ")
          
            
    return report

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
    print(experiments(3, upper=5))
    debug(f"Ended in {round(time.time() - start_time,2)} seconds")
    
    
    
    
    
    
    



