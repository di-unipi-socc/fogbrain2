application(vrApp, [vrDriver, videoStorage, sceneSelector]).
service(videoStorage, [mySQL, ubuntu], 16, []).
service(sceneSelector, [ubuntu], 2, []).
service(vrDriver, [gcc, make], 6, [vrViewer]).
service(s, [gcc], 1, [vrViewer]).
service(s1, [gcc, ubuntu], 2, [vrViewer]).
s2s(videoStorage, sceneSelector, 150, 100).
%s2s(sceneSelector, videoStorage, 0, 0.5).
s2s(sceneSelector, vrDriver, 200, 8).
s2s(vrDriver, sceneSelector, 200, 1).
