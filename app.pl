application(vrApp, [s, s1, vrDriver]).
service(videoStorage, [mySQL, ubuntu], 16, []).
service(sceneSelector, [ubuntu], 2, []).
service(vrDriver, [gcc, make], 2, [vrViewer]).
service(s, [gcc,ubuntu], 2, []).
service(s1, [gcc,ubuntu], 2, []).
s2s(videoStorage, sceneSelector, 150, 16).
s2s(sceneSelector, videoStorage, 150, 0.5).
s2s(sceneSelector, vrDriver, 20, 8).
s2s(vrDriver, sceneSelector, 20, 1).
s2s(s, sceneSelector, 200, 1).