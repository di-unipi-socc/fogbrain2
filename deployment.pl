deployment(vrApp,[on(vrDriver,accesspoint1),on(sceneSelector,cloud0),on(geoLocalisator,cloud1),on(videoStorage,cloud0)],([(cloud0,18),(cloud1,2),(accesspoint1,2)],[(cloud0,cloud1,2),(cloud1,cloud0,2),(accesspoint1,cloud0,1),(cloud0,accesspoint1,8)]),([service(videoStorage,[mySQL,ubuntu],16,[]),service(sceneSelector,[ubuntu],2,[]),service(vrDriver,[gcc,make],2,[vrViewer]),service(geoLocalisator,[gcc,make],2,[])],[s2s(videoStorage,sceneSelector,150,16),s2s(sceneSelector,videoStorage,150,0.5),s2s(sceneSelector,vrDriver,20,8),s2s(vrDriver,sceneSelector,20,1),s2s(geoLocalisator,sceneSelector,50,2),s2s(sceneSelector,geoLocalisator,50,2)])).
