
import networkx as nx
import random as rnd
import math
import os
import json
from datetime import datetime

from pyswip import Prolog, Functor, Atom

from commitsGenerator import *

PATH = "./experiments/commits/"
PATH_REPORTS = "./experiments/reports/"

RUNS = 1
EPOCHS = 1
LOWER = 4
UPPER = 4

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

def print_infrastructure(G,n):

    f = open("./infra.pl","w+")
    for i in range(0,n):
        node = G.nodes[i]
        newnode = 'node(node'+str(i)+', '+node['software']+', '+node['hardware']+', '+node['iot']+').\n'
        f.write(newnode)
    for (i,j) in G.edges():
        link=G.edges[i,j]
        newlink='link(node'+str(i)+', node'+str(j)+', '+str(link['latency'])+', '+str(link['bandwidth'])+').\n'
        f.write(newlink)

    f.close()
    

def generate_infrastructure(n,m,seed = None):
        
    G = nx.generators.random_graphs.barabasi_albert_graph(n,m,seed)

    for i in range(0,n):
        iot = rnd.random() > 0.7 # 30% of the nodes with the iot device
        edge = rnd.random() > 0.2 # 80% of the nodes in the edge, 20% in the cloud

        if (edge):
            G.nodes[i]['hardware'] = str((rnd.choice([2,4,8,16,32])))
        else:
            G.nodes[i]['hardware'] = str((rnd.choice([64,128,256])))

        G.nodes[i]['software'] = rnd.choice( [\
        "[ubuntu, mySQL]", "[ubuntu, mySQL, gcc, make]", "[ubuntu, gcc, make]",
        "[android, gcc, make]", "[gcc, make]",
        #"[android]","[android, mySQL]","[ubuntu]"
        ])

        if (iot):
            G.nodes[i]['iot'] = "[vrViewer]"
        else:
            G.nodes[i]['iot'] = "[]"


    for (i,j) in G.edges():
        G.edges[i,j]['latency'] = rnd.choice([5,10,25,50,100,150,200])
        G.edges[i,j]['bandwidth'] = rnd.choice([2,5,10,25,50,100,150,200,500,1000])

    return G

def change_infrastructure(G):
    return G,"none"

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


def analyse(report):
    analysis = {}
    commits = get_commits(PATH)
    for nodes in report:
        analysis[nodes] = {}
        for commit in commits:
            analysis[nodes][commit] = {"placement":[], "reasoning":[]}
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
    

if __name__ == "__main__":
    import time
    start_time = time.time()
    generate_commits()
    debug("commits generated")
    experiments(RUNS, EPOCHS, LOWER, UPPER)
    debug(f"Ended in {round(time.time() - start_time,2)} seconds")
    
    
    
    
    
    
    



