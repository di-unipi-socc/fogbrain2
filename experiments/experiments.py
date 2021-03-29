import pyswip as p
import builder
import math
import random as rnd
import os
import time

rnd.seed(481183)

PATH = "./experiments/commits/"
RUNS = 1
EPOCHS = 80
MIN = 7
MAX = 13


def main():
    commits = get_commits()
    for nodes in [2**i for i in range(MIN,MAX+1)]:
        print("Starting with", nodes, "nodes.")
        c1, c2, ratios = simulation(nodes, commits)
        print(ratios)

        c3 = zip(c1,c2)
        c4 = [a/b for (a,b) in c3]
        file = 'nodes'+str(nodes)+'.txt'
        with open(file, 'a+') as f:
            f.write(str(c1))
            f.write(str(c2))
            f.write(str(c4))
            f.write(str(ratios))
     
    
def get_commits():
    commits = os.listdir(PATH)
    commits.sort()
    return commits

def simulation(nodes, commits):
    cr_inferences = [0]*len(commits)
    nocr_inferences = [0]*len(commits)
    ratios = [0]*len(commits)

    for j in range(RUNS):
        app_spec = ""
        current_commit = 0

        infra = builder.generate_graph_infrastructure(nodes, nodes/4)
        builder.print_graph_infrastructure(infra)

        prolog = p.Prolog()
        prolog.consult('fogbrain.pl')

        i = 0

        print("**** Starting run ", j)
        while i < EPOCHS:
            if rnd.random() > 0.5 and i % len(commits) != 0:
                time.sleep(10)
                infra=builder.change_graph_infrastructure(infra)
                builder.print_graph_infrastructure(infra)

            app_spec = commits[current_commit]
            query = "fogBrain('" + PATH + app_spec + "', 'infra.pl', P, P1, InferencesCR, InferencesNoCR)"

            try:
                q = None
                q = prolog.query(query)
                result = next(q)
                cr_inferences[current_commit] += result["InferencesCR"]
                nocr_inferences[current_commit] += result["InferencesNoCR"]
                ratios[current_commit] += ratios[current_commit] + (result["InferencesNoCR"] / result["InferencesCR"])
                i = i + 1
                #print(result["InferencesCR"],"-",result["InferencesNoCR"])
                if i % len(commits) == 0:      
                    current_commit = (current_commit + 1) % len(commits)
                
            except StopIteration:
                print("StopIteration! Ooopsieee")
                infra=builder.change_graph_infrastructure(infra)
                builder.print_graph_infrastructure(infra)
    
    ratios = [r/10 for r in ratios]

    return cr_inferences, nocr_inferences, ratios

main()

             

            



            
            


            








