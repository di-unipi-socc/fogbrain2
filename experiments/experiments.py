import pyswip as p
import builder
import math
import random as rnd
import os

rnd.seed(481183)

PATH = "./experiments/commits/"
RUNS = 10
EPOCHS = 140
MIN = 4
MAX = 8

def main():
    commits = get_commits()
    for nodes in [2**i for i in range(MIN,MAX)]:
        c1, c2 = simulation(nodes, commits)
        print(c1)
        print(c2)
     
    
def get_commits():
    commits = os.listdir(PATH)
    commits.sort()
    return commits

def simulation(nodes, commits):
    cr_inferences = [0]*len(commits)
    nocr_inferences = [0]*len(commits)

    for j in range(RUNS):
        app_spec = ""
        current_commit = 0
        infra = builder.generate_graph_infrastructure(nodes, int(math.log(nodes)))
        builder.print_graph_infrastructure(infra)

        prolog = p.Prolog()
        prolog.consult('fogbrain.pl')
        i = 0
        while i < EPOCHS:

            if rnd.random() > 0.5 and i % len(commits) != 0:
                infra=builder.change_graph_infrastructure(infra)
                builder.print_graph_infrastructure(infra)

            app_spec = commits[current_commit]
            query = "fogBrain('" + PATH + app_spec + "', 'infra.pl', P, InferencesCR, InferencesNoCR)"

            try:
                result = next(prolog.query(query))
                cr_inferences[current_commit] += result["InferencesCR"]
                nocr_inferences[current_commit] += result["InferencesNoCR"]
                i = i + 1
                if i % COMMIT == 0:      
                    current_commit = (current_commit + 1) % len(commits)
                
            except StopIteration:
                print("StopIteration! Ooopsieee")

    return cr_inferences, nocr_inferences

main()

             

            



            
            


            








