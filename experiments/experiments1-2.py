
import random
import os
import sys
import json

import shutil

from pyswip import Prolog, Functor, Atom

from builder import builder

from commitsGenerator import *

from datetime import datetime

PATH = "./experiments/commits/"

PATH_REPORTS = "./experiments/reports/"

PATH_INFRA = "./experiments/infrastructures/"

def parse(query):
    if isinstance(query,dict):
        ans = {}
        for k,v in query.items():
            ans[k] = parse(v)
        return ans
    elif isinstance(query,list):
        ans = []
        for v in query:
            ans.append(parse(v))
        return ans
    elif isinstance(query,Atom):
        return query.value
    elif isinstance(query, Functor):
        fun = query.name.value
        if fun != ",": #prolog tuple
            ans = (fun,parse(query.args))
        else:
            ans = tuple(parse(query.args))
        return ans
    else:
        return query

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
    
    app.addService("tokensDealer", ["ubuntu", "mySQL"], 20, [])
    app.addService("userProfiler", ["gcc","make"], 2, [])
    app.addS2S("userProfiler", "sceneSelector", 50, 2)
    app.addS2S("sceneSelector", "userProfiler", 50, 2)
    app.addS2S("userProfiler", "tokensDealer", 200, 0.5)
    app.addS2S("tokensDealer", "userProfiler", 200, 1)
    add_commit(app, "added2Services", DIR=PATH)
    
    app.removeService("tokensDealer")
    add_commit(app, "removedService", DIR=PATH)
    
    app.modifyService("videoStorage", ["ubuntu","mySQL"], 30, [])
    app.modifyService("userProfiler", ["gcc","make"], 2, ["vrViewer"])
    add_commit(app, "changed2Services", DIR=PATH)
    
    app.addS2S("userProfiler", "videoStorage", 500, 1)
    app.addS2S("videoStorage", "userProfiler", 500, 1)
    add_commit(app, "added2S2S", DIR=PATH)
    
    app.removeS2S("sceneSelector","userProfiler")
    add_commit(app, "removedS2S", DIR=PATH)
    
    app.modifyS2S("videoStorage", "userProfiler", 200, 1)
    app.modifyS2S("userProfiler", "videoStorage", 200, 2)
    add_commit(app, "changed2S2S", DIR=PATH)
    

def generate_infrastructure(nodesnumber):
    builder(nodesnumber)
    
def debug(msg):
    print(f"* {msg} ({datetime.now().strftime('%d/%m/%Y %H:%M:%S')})")

def do_experiments(runs, nodes):
    #TODO: check if no placement availbale
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
            try:
                analysis[nodes][commit]["reasoning"] = sum(analysis[nodes][commit]["reasoning"])/len(analysis[nodes][commit]["reasoning"])
            except Exception as e:
                analysis[nodes][commit]["reasoning"] = "exception "+e.__class__.__name__
            try:
                analysis[nodes][commit]["placement"] = sum(analysis[nodes][commit]["placement"])/len(analysis[nodes][commit]["placement"])
            except Exception as e:
                analysis[nodes][commit]["placement"] = "exception "+e.__class__.__name__
            try:
                analysis[nodes][commit]["ratio"] = analysis[nodes][commit]["placement"]/analysis[nodes][commit]["reasoning"]
            except Exception as e:
                analysis[nodes][commit]["ratio"] = "exception "+e.__class__.__name__
            
        
    return analysis
        

def experimentsPhase1(nodes):
    debug("STARTING PHASE 1")
    try:
        os.mkdir(PATH_REPORTS)
    except OSError:
        pass
    report = {}
    generate_infrastructure(nodes)
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
    generate_commits()
    debug("commits generated")
    experimentsPhase1(1)
    experimentsPhase2()
    debug(f"Ended in {round(time.time() - start_time,2)} seconds")
    
    
    
    
    
    
    



