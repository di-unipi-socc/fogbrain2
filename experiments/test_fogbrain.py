from .app import App
from .infra import Infra

from pyswip import Prolog, Functor, Atom

import unittest 

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

class FogBrainTest(unittest.TestCase):
    
    ############################ 
    #### setup and teardown #### 
    ############################ 

    def setupApp(self):
        #app.addService("videoStorage", ["mySQL", "ubuntu"], 16, [])
        self.app.addService("sceneSelector", ["ubuntu"], 2, [])
        self.app.addService("vrDriver", ["gcc", "make"], 2, ["vrViewer"])

        #app.addS2S("videoStorage", "sceneSelector", 150, 101)
        #app.addS2S("sceneSelector", "videoStorage", 150, 0.5)
        self.app.addS2S("sceneSelector", "vrDriver", 20, 8)
        self.app.addS2S("vrDriver", "sceneSelector", 20, 1)

        self.app.upload()


    def setupInfra(self):
        self.infra.addNode("cloud", ["ubuntu", "mySQL", "gcc", "make"], "inf", [])
        self.infra.addNode("ispdatacentre", ["ubuntu", "mySQL"], 50, [])
        self.infra.addNode("cabinetserver", ["ubuntu", "mySQL"], 20, [])
        self.infra.addNode("accesspoint", ["ubuntu", "gcc", "make"], 4, ["vrViewer"])
        self.infra.addNode("smartphone", ["android", "gcc", "make"], 8, ["vrViewer"])

        self.infra.addLink("cloud", "ispdatacentre", 110, 1000)
        self.infra.addLink("cloud", "cabinetserver", 135, 100)
        self.infra.addLink("cloud", "accesspoint", 148, 20)
        self.infra.addLink("cloud", "smartphone", 150, 18 )
        self.infra.addLink("ispdatacentre", "cloud", 110, 1000)
        self.infra.addLink("ispdatacentre", "cabinetserver", 25, 500)
        self.infra.addLink("ispdatacentre", "accesspoint", 38, 50)
        self.infra.addLink("ispdatacentre", "smartphone", 40, 35)
        self.infra.addLink("cabinetserver", "cloud", 135, 100)
        self.infra.addLink("cabinetserver", "ispdatacentre", 25, 500)
        self.infra.addLink("cabinetserver", "accesspoint", 13, 50)
        self.infra.addLink("cabinetserver", "smartphone", 15, 35)
        self.infra.addLink("accesspoint", "cloud", 148, 3)
        self.infra.addLink("accesspoint", "ispdatacentre", 38, 4)
        self.infra.addLink("accesspoint", "cabinetserver", 13, 4)
        self.infra.addLink("accesspoint", "smartphone", 2, 70)
        self.infra.addLink("smartphone", "cloud", 150, 2)
        self.infra.addLink("smartphone", "ispdatacentre", 40, 2.5)
        self.infra.addLink("smartphone", "cabinetserver", 15, 3)
        self.infra.addLink("smartphone", "accesspoint", 2, 70)

        self.infra.upload()

    # executed prior to each test 
    def setUp(self): 
        self.app = App("vrApp","app.pl")
        self.infra = Infra("infra.pl")
        self.prolog = Prolog()
        self.prolog.consult("fogbrain.pl")

        self.setupApp()
        self.setupInfra()

    # executed after each test 
    def tearDown(self): 
        pass 


    ###############
    #### tests #### 
    ############### 

    def test_two_services(self):
        deployment = self.prolog.query("make,fogBrain('app.pl',_),deployment(vrApp, Placement, AllocHW, AllocBW, (ContextServices, ContextS2S)).").__next__()
        ans = parse(deployment)     
        res = {'Placement': [('on', ['vrDriver', 'accesspoint']), ('on', ['sceneSelector', 'cabinetserver'])], 'AllocHW': [('cabinetserver', 2), ('accesspoint', 2)], 'AllocBW': [('accesspoint', ('cabinetserver', 1)), ('cabinetserver', ('accesspoint', 8))], 'ContextServices': [('service', ['sceneSelector', ['ubuntu'], 2, []]), ('service', ['vrDriver', ['gcc', 'make'], 2, ['vrViewer']])], 'ContextS2S': [('s2s', ['sceneSelector', 'vrDriver', 20, 8]), ('s2s', ['vrDriver', 'sceneSelector', 20, 1])]}
        self.assertEqual(ans,res,ans)

if __name__ == '__main__':
    unittest.main()