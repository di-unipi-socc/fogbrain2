deployment(vrApp,[on(userProfiler,node375),on(sceneSelector,node4),on(vrDriver,node474),on(videoStorage,node32)],([(node32,30),(node474,2),(node4,2),(node375,2)],[(node4,node32,0.5),(node4,node474,8),(node32,node4,16),(node474,node4,1),(node375,node4,2),(node375,node32,2),(node32,node375,1)]),([service(videoStorage,[ubuntu,mySQL],30,[]),service(sceneSelector,[ubuntu],2,[]),service(vrDriver,[gcc,make],2,[vrViewer]),service(userProfiler,[gcc,make],2,[vrViewer])],[s2s(videoStorage,sceneSelector,150,16),s2s(sceneSelector,videoStorage,150,0.5),s2s(sceneSelector,vrDriver,20,8),s2s(vrDriver,sceneSelector,20,1),s2s(userProfiler,sceneSelector,50,2),s2s(userProfiler,videoStorage,60,2),s2s(videoStorage,userProfiler,60,1)])).
