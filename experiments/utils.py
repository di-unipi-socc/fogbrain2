from pyswip import Prolog, Functor, Atom
from datetime import datetime
import os


PATH = "./experiments/commits/"
PATH_REPORTS = "./experiments/reports/"
PATH_INFRA = "./experiments/infrastructures/"

def debug(msg):
    print(f"* {msg} ({datetime.now().strftime('%d/%m/%Y %H:%M:%S')})")

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