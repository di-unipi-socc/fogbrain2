import networkx as nx
import random as rnd
import math

def writeNodes(basename, number, caps, lista, f):
    for i in range(number):
        name = basename + str(i)
        node = "node(" + name +"," + caps +").\n"
        lista.append(name)
        f.write(node)

def printLinks(list1, list2, qos, f):
    for n1 in list1:
        for n2 in list2:
            if n1 != n2:
                link = "link(" + n1 + ", " + n2 + ", " + qos + ").\n"
                f.write(link)

def builder(nodesnumber, path="infra.pl"):

    f = open(path, "w+")

    CLOUDS = nodesnumber
    ISPS = nodesnumber
    CABINETS = nodesnumber
    ACCESSPOINTS = nodesnumber
    SMARTPHONES = nodesnumber

    clouds = []
    isps = []
    cabinets = []
    accesspoints = []
    smartphones = []

    writeNodes("cloud", CLOUDS, "[ubuntu, mySQL, gcc, make], inf, []", clouds, f)
    writeNodes("ispdatacentre", ISPS, "[ubuntu, mySQL], 50, []", isps, f)
    writeNodes("cabinetserver", CABINETS, "[ubuntu, mySQL], 20, []", cabinets, f)
    writeNodes("accesspoint", ACCESSPOINTS, "[ubuntu, gcc, make], 4, [vrViewer]", accesspoints, f)
    writeNodes("smartphone", SMARTPHONES, "[android, gcc, make], 8, [vrViewer]", smartphones, f)

    f.write("\n")

    printLinks(clouds, clouds, "20, 1000", f)
    printLinks(clouds, isps, "110, 1000", f)
    printLinks(clouds, cabinets, "135, 100", f)
    printLinks(clouds, accesspoints, " 148, 20", f)
    printLinks(clouds, smartphones, "150, 18", f)

    f.write("\n")

    printLinks(isps, clouds, "110, 1000", f)
    printLinks(isps, isps, "20, 1000", f)
    printLinks(isps, cabinets, "25, 500", f)
    printLinks(isps, accesspoints, "38, 50", f)
    printLinks(isps, smartphones, "20, 1000", f)

    f.write("\n")

    printLinks(cabinets, clouds, "135, 100", f)
    printLinks(cabinets, isps, "25, 500", f)
    printLinks(cabinets, cabinets, "20, 1000", f)
    printLinks(cabinets, accesspoints, "13, 50", f)
    printLinks(cabinets, smartphones, "15, 35", f)

    f.write("\n")

    printLinks(accesspoints, clouds, "148, 3", f)
    printLinks(accesspoints, isps, "38, 4", f)
    printLinks(accesspoints, cabinets, "13, 4", f)
    printLinks(accesspoints, accesspoints, "10, 50", f)
    printLinks(accesspoints, smartphones, "2, 70", f)

    f.write("\n")


    printLinks(smartphones, clouds, "150, 2", f)
    printLinks(smartphones, isps, "40, 2.5", f)
    printLinks(smartphones, cabinets, "15, 3", f)
    printLinks(smartphones, accesspoints, "2, 70", f)
    printLinks(smartphones, smartphones, "15, 50", f)

    f.close()

def set_node_as_cloud(node):
    rand = rnd.random()
    if rand > 0.9:
        node["software"] = "[]"
    elif rand > 0.7:
        node["software"] = "[ubuntu]"
    else:
        node["software"] = "[ubuntu, mySQL, gcc, make]"

    rand = rnd.random()
    if rand > 0.9:
        node["hardware"] = "0"
    elif rand > 0.7:
        node["hardware"] = "100"
    else:
        node["hardware"] = "inf"

    node["iot"] = "[]"
    node["handler"] = set_node_as_cloud
    return node

def set_node_as_ispdatacentre(node):
    rand = rnd.random()
    if rand > 0.9:
        node["software"] = "[]"
    elif rand > 0.7:
        node["software"] = "[ubuntu]"
    else:
        node["software"] = "[ubuntu, mySQL]"

    rand = rnd.random()
    if rand > 0.9:
        node["hardware"] = "0"
    elif rand > 0.7:
        node["hardware"] = "25"
    else:
        node["hardware"] = "50"
        
    node["iot"] = "[]"
    node["handler"] = set_node_as_ispdatacentre
    return node

def set_node_as_cabinetserver(node):
    rand = rnd.random()
    if rand > 0.9:
        node["software"] = "[]"
    elif rand > 0.7:
        node["software"] = "[ubuntu]"
    else:
        node["software"] = "[ubuntu, mySQL]"

    rand = rnd.random()
    if rand > 0.9:
        node["hardware"] = "0"
    elif rand > 0.7:
        node["hardware"] = "10"
    else:
        node["hardware"] = "20"

    node["iot"] = "[]"
    node["handler"] = set_node_as_cabinetserver
    return node

def set_node_as_accesspoint(node):
    rand = rnd.random()
    if rand > 0.9:
        node["software"] = "[]"
    elif rand > 0.7:
        node["software"] = "[ubuntu]"
    else:
        node["software"] = "[ubuntu, gcc, make]"

    rand = rnd.random()
    if rand > 0.9:
        node["hardware"] = "0"
    elif rand > 0.7:
        node["hardware"] = "2"
    else:
        node["hardware"] = "4"
    
    if rnd.random() > 0.97: #3%
        node["iot"] = "[vrViewer]"
    else:
         node["iot"] = "[]"
    node["handler"] = set_node_as_accesspoint
    return node

def set_node_as_smartphone(node):
    rand = rnd.random()
    if rand > 0.9:
        node["software"] = "[]"
    elif rand > 0.7:
        node["software"] = "[andorid]"
    else:
        node["software"] = "[android, gcc, make]"

    rand = rnd.random()
    if rand > 0.9:
        node["hardware"] = "0"
    elif rand > 0.7:
        node["hardware"] = "4"
    else:
        node["hardware"] = "8"

    if rnd.random() > 0.95: #5%
        node["iot"] = "[vrViewer]"
    else:
         node["iot"] = "[]"

    node["handler"] = set_node_as_smartphone
    return node

def set_link(link):
    link['latency'] = rnd.choice([5,10,25,50,100,150,200])
    link['bandwidth'] = rnd.choice([2, 7, 20, 50, 100, 500])

def generate_graph_infrastructure(n,m,seed = None):

    G = nx.generators.random_graphs.barabasi_albert_graph(n,m,seed)

    for i in range(0,n):
        rand = rnd.random()
        if rand > 0.9: #10%
            set_node_as_cloud(G.nodes[i])
        elif rand > 0.7: #20%
            set_node_as_ispdatacentre(G.nodes[i])
        elif rand > 0.4: #30%
            set_node_as_cabinetserver(G.nodes[i])
        elif rand > 0.2: #20%
            set_node_as_accesspoint(G.nodes[i])
        else: #20%
            set_node_as_smartphone(G.nodes[i])

    for (i,j) in G.edges():
        set_link(G.edges[i,j])

    return G

def change_graph_infrastructure(G):
    return G,"none"
    
def print_graph_infrastructure(G,n):
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

if __name__ == "__main__":
    #builder(2)
    nodes = 16
    G = generate_graph_infrastructure(nodes, (int(math.log2(nodes))))
    print_graph_infrastructure(G, nodes)