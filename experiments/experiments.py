import pyswip as p
import builder
import math
import random as rnd
import os
import sys
import time

#rnd.seed(553516)

PATH = "./experiments/commits/"
RUNS = 5
EPOCHS = 70

NODENUMBERS = [2, 4, 8, 16, 32, 64, 128, 256, 512]


def main():
    file = './deployment.pl'
    with open(file, 'w') as f:
        f.write(str(""))

    commits = get_commits()
    for nodes in NODENUMBERS:
        print("Starting with", str(5*nodes), "nodes.")
        cr_inferences, nocr_inferences, ratios_infs, cr_time, nocr_time, ratios_time = simulation(nodes, commits)
        #sum(cr_infs_avg)/sum(nicr_inf_avg)
        avg_nocr_infs = avg_list(nocr_inferences)
        avg_nocr_time = avg_list(nocr_time)
        avg_cr_infs = avg_list(cr_inferences)
        avg_cr_time = avg_list(cr_time)
        
        avg_infs_ratio = avg_list(ratios_infs)
        avg_time_ratio = avg_list(ratios_time)

        avg_infs = sum(avg_infs_ratio)/len(avg_infs_ratio)
        avg_time = sum(avg_time_ratio)/len(avg_time_ratio)

        print("Average inf.s speedup per commit:", avg_infs_ratio)
        print("Overall average inf.s speedup:", avg_infs)
        print("Average time speed up per commit:", avg_time_ratio)
        print("Overall average time speedup:", avg_time)


        file = './results/experiments_nodes'+str(nodes)+'.txt'
        with open(file, 'w+') as f:
            f.write(str(avg_nocr_infs)+"\n\n")
            f.write(str(avg_nocr_time)+"\n\n")  
            f.write(str(avg_cr_infs)+"\n\n")
            f.write(str(avg_cr_time)+"\n\n")  

            f.write(str(avg_infs_ratio)+"\n\n")
            f.write(str(avg_time_ratio)+"\n\n")  

            f.write(str(avg_infs)+"\n\n")
            f.write(str(avg_time)+"\n\n")  
            

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
    return result

def list_of_list(n):
    ls=[]
    for _ in range(n):
        ls.append([])
    return ls

def simulation(nodes, commits):
    cr_time = list_of_list(len(commits))
    nocr_time = list_of_list(len(commits))
    ratios_time = list_of_list(len(commits))
    cr_inferences = list_of_list(len(commits))
    nocr_inferences = list_of_list(len(commits))
    ratios = list_of_list(len(commits))
    faults = 0

    prolog = p.Prolog()
    prolog.consult('fogbrain.pl')  
    my_query('set_seed', prolog)

    for j in range(RUNS):
        app_spec = ""
        current_commit = 0

        #infra = builder.generate_graph_infrastructure(nodes, math.log2(nodes))
        #builder.print_graph_infrastructure(infra)
        builder.builder(nodes)
        #print("built infra")
        
        my_query('load_infra.', prolog)
        #print("loaded")

        i = 0

        print("**** Starting run ", j)
        while i < EPOCHS:
         
            app_spec = commits[current_commit]

            try:

                query_no_cr = "p('" + PATH + app_spec + "', P, Infs, Time)"
                no_cr = my_query(query_no_cr, prolog)

                query_cr = "cr('" + PATH + app_spec + "', P, Infs, Time)"
                cr = my_query(query_cr, prolog)

                inferences_cr = cr["Infs"]
                inferences_nocr = no_cr["Infs"]
                time_cr = cr["Time"]
                if (time_cr == 0):
                    time_cr = sys.float_info.min
                time_nocr = no_cr["Time"]
                                
                cr_inferences[current_commit].append(inferences_cr)
                nocr_inferences[current_commit].append(inferences_nocr)
                ratios[current_commit].append(inferences_nocr/inferences_cr)

                cr_time[current_commit].append(time_cr)
                nocr_time[current_commit].append(time_nocr)
                ratios_time[current_commit].append(time_nocr/time_cr)

                #print(i,":", no_cr["InferencesNoCR"], "/", cr["InferencesCR"], "=", str(no_cr["InferencesNoCR"] / cr["InferencesCR"]))
                #print(i,":", no_cr["TimeNoCR"], "/", cr["TimeCR"], "=", str(no_cr["TimeNoCR"] / cr["TimeCR"]))

                i = i + 1
                #print(result["InferencesCR"],"-",result["InferencesNoCR"])
                if i % 10 == 0:  
                    #print("completed commit:", current_commit)    
                    current_commit = (current_commit + 1) % len(commits)
                
            except StopIteration:
                faults += 1
                print("fault")
                builder.builder(nodes)
                #infra=builder.change_graph_infrastructure(infra)#.change_graph_infrastructure(infra)
                #builder.print_graph_infrastructure(infra)
                my_query('load_infra.', prolog)
                print('loaded1')
                
               
    return cr_inferences, nocr_inferences, ratios, cr_time, nocr_time, ratios_time

main()
