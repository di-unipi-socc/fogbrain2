from pyswip import Prolog

class App:

    def __init__(self, id, services):
        self._id = id
        self._services = services

    def __str__(self):
        return ("application("+self._id+", "+str(self._services)+").\n").replace("'","")

    def services(self, services):
        self._services = services

class Service:

    def __init__(self, id, sw, hw, t):
        self._id = id
        self._sw = sw
        self._hw = hw
        self._t = t

    def __str__(self):
        return ("service("+self._id+", "+str(self._sw)+", "+str(self._hw)+", "+str(self._t)+").\n").replace("'","")

    def sw(self, sw):
        self._sw = sw
    
    def hw(self, hw):
        self._hw = hw

    def t(self, t):
        self._t = t

class S2S:

    def __init__(self, s1, s2, lat, bw):
        self._s1 = s1
        self._s2 = s2
        self._lat = lat
        self._bw = bw

    def __str__(self):
        return ("s2s("+self._s1+", "+self._s2+", "+str(self._lat)+", "+str(self._bw)+").\n").replace("'","")

    def lat(self, lat):
        self._lat = lat
    
    def hw(self, bw):
        self._bw = bw

def upload(file, app, services, s2ss):
    with open(file,"w") as f:
        f.write(str(app))
        for s in services:
            f.write(str(s))
        for s2s in s2ss:
            f.write(str(s2s))

prolog = Prolog()

app = App("vrApp", ["vrDriver", "videoStorage", "sceneSelector"])

services = [
    Service("videoStorage", ["mySQL", "ubuntu"], 16, []),
    Service("sceneSelector", ["ubuntu"], 2, []),
    Service("vrDriver", ["gcc", "make"], 6, ["vrViewer"]),
    Service("s", ["gcc"], 1, ["vrViewer"]),
    Service("s1", ["gcc","ubuntu"], 2, ["vrViewer"]),
]

s2ss = [
    S2S("videoStorage", "sceneSelector", 150, 100),
    S2S("sceneSelector", "videoStorage", 0, 0.5),
    S2S("sceneSelector", "vrDriver", 200, 8),
    S2S("vrDriver", "sceneSelector", 200, 1),
]

upload("app.pl", app, services, s2ss)
prolog.consult("fogbrain.pl")
prolog.query("make.")
print(prolog.query("fogBrain(vrApp,P)."))

