from app import App

import os

def add_commit(commit, name, DIR="./commits/", BASE_NAME="commit",SEPARATOR="-"):
    add_commit.index = getattr(add_commit, 'index', -1) + 1
    
    file_name = DIR+BASE_NAME+str(add_commit.index)+SEPARATOR+name+".pl"
    
    commit.upload(file_name)
    return file_name
    
def initial_commit():
    app = App("vrApp","app.pl")
    app.addService("videoStorage", ["mySQL", "ubuntu"], 16, [])
    app.addService("sceneSelector", ["ubuntu"], 2, [])
    app.addService("vrDriver", ["gcc", "make"], 2, ["vrViewer"])

    app.addS2S("videoStorage", "sceneSelector", 150, 16)
    app.addS2S("sceneSelector", "videoStorage", 150, 0.5)
    app.addS2S("sceneSelector", "vrDriver", 20, 8)
    app.addS2S("vrDriver", "sceneSelector", 20, 1)
    
    return app
    

if __name__ == "__main__":
    try:
        os.mkdir(DIR)
    except OSError:
        pass   
    
    app = initial_commit()
    add_commit(app, "initial")
    
    app.removeService("videoStorage")
    add_commit(app, "removedService")
    
    