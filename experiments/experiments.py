import pyswip as p
import builder
import math
import random as rnd
import os
import time

rnd.seed(481183)

PATH = "./experiments/commits/"
RUNS = 20
EPOCHS = 70
NODENUMBERS = [100, 200, 300, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000]


def main():
    file = './deployment.pl'
    with open(file, 'w') as f:
        f.write(str(""))

    commits = get_commits()
    for nodes in NODENUMBERS:
        print("Starting with", nodes, "nodes.")
        c1, c2, ratios, faults = simulation(nodes, commits)

        c1_avg = avg_list(c1)
        c2_avg = avg_list(c2)
        ratio_avg = avg_list(ratios)

        print(c1_avg)
        print()
        print(c2_avg)
        print()
        print(ratio_avg)
        print()
        print(faults)
        
        file = './results/nodes'+str(nodes)+'.txt'
        with open(file, 'a') as f:
            f.write(str(c1))
            f.write(str(c2))  
            f.write(str(ratios))
            f.write(str(c1_avg))
            f.write(str(c2_avg))
            f.write(str(ratio_avg))
            f.write(str(faults))

def avg_list(l):
    res = [0] * len(l)
    i = 0
    for el in l:
        res[i] = sum(el)/len(el)
        i = i + 1
    return res
     
def get_commits():
    commits = os.listdir(PATH)
    commits.sort()
    return commits

def my_query(s, prolog):
    q = prolog.query(s)
    result = next(q) 
    return result, prolog

def list_of_list(n):
    ls=[]
    for _ in range(n):
        ls.append([])
    return ls

def simulation(nodes, commits):
    cr_inferences = list_of_list(len(commits))
    nocr_inferences = list_of_list(len(commits))
    ratios = list_of_list(len(commits))
    faults = 0

    prolog = p.Prolog()
    prolog.consult('fogbrain.pl')  

    for j in range(RUNS):
        app_spec = ""
        current_commit = 0

        infra = builder.generate_graph_infrastructure(nodes, math.log2(nodes))
        builder.print_graph_infrastructure(infra)

        
        my_query('loadInfra.', prolog)

        i = 0

        print("**** Starting run ", j)
        while i < EPOCHS:
         
            app_spec = commits[current_commit]

            try:

                query_cr = "cr('" + PATH + app_spec + "', P, InferencesCR, TimeCR)"
                cr, prolog = my_query(query_cr, prolog)

                query_no_cr = "p('" + PATH + app_spec + "', P, InferencesNoCR, TimeNoCR)"
                no_cr, prolog = my_query(query_no_cr, prolog)

                
                
                (cr_inferences[current_commit]).append(cr["InferencesCR"])
                (nocr_inferences[current_commit]).append(no_cr["InferencesNoCR"])
                (ratios[current_commit]).append(no_cr["InferencesNoCR"] / cr["InferencesCR"])
                #print(i,":", no_cr["InferencesNoCR"], "/", cr["InferencesCR"], "=", str(no_cr["InferencesNoCR"] / cr["InferencesCR"]))
                #print(i,":", no_cr["TimeNoCR"], "/", cr["TimeCR"], "=", str(no_cr["TimeNoCR"] / cr["TimeCR"]))

                i = i + 1
                #print(result["InferencesCR"],"-",result["InferencesNoCR"])
                if i % 10 == 0:  
                    #print("commit:", current_commit)    
                    current_commit = (current_commit + 1) % len(commits)
                
            except StopIteration:
                faults += 1
                infra=builder.change_graph_infrastructure(infra)#.change_graph_infrastructure(infra)
                builder.print_graph_infrastructure(infra)
                my_query('loadInfra.', prolog)
               
    return cr_inferences, nocr_inferences, ratios, faults

main()