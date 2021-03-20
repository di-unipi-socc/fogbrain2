from .app import App
from .infra import Infra

from pyswip import Prolog

import unittest 

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

    def test(self):
        deployment = self.prolog.query("make,fogBrain('app.pl',_),deployment(vrApp, Placement, AllocHW, AllocBW, (ContextServices, ContextS2S)).").__next__()
        self.assertFalse(True,deployment["Placement"])

if __name__ == '__main__':
    unittest.main()