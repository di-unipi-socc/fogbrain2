application(vrApp, [videoStorage, sceneSelector, vrDriver, usersProfiler]).

service(videoStorage, [ubuntu, mySQL], 30, []).
service(sceneSelector, [ubuntu], 2, []).
service(vrDriver, [gcc, make], 2, [vrViewer]).
service(usersProfiler, [gcc, make], 2, [vrViewer]).

s2s(videoStorage, sceneSelector, 150, 16).
s2s(sceneSelector, videoStorage, 150, 0.5).
s2s(sceneSelector, vrDriver, 20, 8).
s2s(vrDriver, sceneSelector, 20, 1).

