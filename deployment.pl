deployment(vrApp,[on(vrDriver,accesspoint2),on(sceneSelector,cloud0),on(geoLocalisator,cloud0),on(videoStorage,cloud0)],([(cloud0,20),(accesspoint2,2)],[(accesspoint2,cloud0,1),(cloud0,accesspoint2,8)]),([service(videoStorage,[mySQL,ubuntu],16,[]),service(sceneSelector,[ubuntu],2,[]),service(vrDriver,[gcc,make],2,[vrViewer]),service(geoLocalisator,[gcc,make],2,[])],[s2s(videoStorage,sceneSelector,150,16),s2s(sceneSelector,videoStorage,150,0.5),s2s(sceneSelector,vrDriver,20,8),s2s(vrDriver,sceneSelector,20,1),s2s(geoLocalisator,sceneSelector,50,2),s2s(sceneSelector,geoLocalisator,50,2)])).
