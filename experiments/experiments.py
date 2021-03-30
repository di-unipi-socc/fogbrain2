import pyswip as p
import builder
import math
import random as rnd
import os
import time

rnd.seed(12)

PATH = "./experiments/commits/"
RUNS = 1
EPOCHS = 80
NODENUMBERS = [500, 600]


def main():
    file = './deployment.pl'
    with open(file, 'w') as f:
        f.write(str(""))

    commits = get_commits()
    for nodes in NODENUMBERS:
        print("Starting with", nodes, "nodes.")
        c1, c2, ratios = simulation(nodes, commits)

        c1_avg = avg_list(c1)
        c2_avg = avg_list(c2)
        ratio_avg = avg_list(ratios)

        print(c1_avg)
        print()
        print(c2_avg)
        print()
        print(ratio_avg)
        
        # file = './results/nodes'+str(nodes)+'.txt'
        # with open(file, 'a') as f:
        #     f.write(str(c1))
        #     f.write(str(c2))                                                                                         
        #     f.write(str(c4))
        #     f.write(str(ratios))

def avg_list(l):
    res = [0] * len(l)
    i = 0
    for el in l:
        print(el)
        res[i] = sum(el)/len(el)
        i = i + 1
    return res
     
def get_commits():
    commits = os.listdir(PATH)
    commits.sort()
    return commits

def my_query(s):
    prolog = p.Prolog()
    prolog.consult('fogbrain.pl')  
    q = prolog.query(s)
    result = next(q) 
    return result, prolog

def simulation(nodes, commits):
    cr_inferences = [[]]*len(commits)
    nocr_inferences = [[]]*len(commits)
    ratios = [[]]*len(commits)

    for j in range(RUNS):
        app_spec = ""
        current_commit = 0

        infra = builder.generate_graph_infrastructure(nodes, math.log2(nodes))
        builder.print_graph_infrastructure(infra)

        i = 0

        print("**** Starting run ", j)
        while i < EPOCHS:
            if rnd.random() > 1 and i % 10 != 0:
                infra=builder.change_graph_infrastructure(infra)
                builder.print_graph_infrastructure(infra)

            app_spec = commits[current_commit]
            query = "fogBrain('" + PATH + app_spec + "', 'infra.pl', P, P1, InferencesCR, TimeCR, InferencesNoCR, TimeNoCR)."
#p(AppSpec, Infra, NewPlacement, InferencesNoCR, TimeNoCR) :-
#cr(AppSpec, Infra, NewPlacement, InferencesNoCR, TimeNoCR) :-
            

            try:
                query_no_cr = "p('" + PATH + app_spec + "', 'infra.pl', P, InferencesNoCR, TimeNoCR)"
                no_cr, prolog = my_query(query_no_cr)
    
                del prolog

                query_cr = "cr('" + PATH + app_spec + "', 'infra.pl', P, InferencesCR, TimeCR)"
                cr, prolog = my_query(query_cr)

                del prolog
                
                (cr_inferences[current_commit]).append(cr["InferencesCR"])
                (nocr_inferences[current_commit]).append(no_cr["InferencesNoCR"])
                ratios[current_commit].append(no_cr["InferencesNoCR"] / cr["InferencesCR"])
                print(i,":", no_cr["InferencesNoCR"], "/", cr["InferencesCR"], "=", str(no_cr["InferencesNoCR"] / cr["InferencesCR"]))
                print(i,":", no_cr["TimeNoCR"], "/", cr["TimeCR"], "=", str(no_cr["TimeNoCR"] / cr["TimeCR"]))

                i = i + 1
                #print(result["InferencesCR"],"-",result["InferencesNoCR"])
                if i % 10 == 0:  
                    print("commit:", current_commit)    
                    current_commit = (current_commit + 1) % len(commits)
                
            except StopIteration:
                print("StopIteration! Ooopsieee")
                infra=builder.change_graph_infrastructure(infra)
                builder.print_graph_infrastructure(infra)

    return cr_inferences, nocr_inferences, ratios

main()

             

            



            
            


            








