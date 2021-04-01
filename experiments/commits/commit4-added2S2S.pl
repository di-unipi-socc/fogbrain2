:-dynamic application/2.
:-dynamic service/4.
:-dynamic s2s/4.

application(vrApp, [videoStorage, sceneSelector, vrDriver, userProfiler]).

service(videoStorage, [ubuntu, mySQL], 30, []).
service(sceneSelector, [ubuntu], 2, []).
service(vrDriver, [gcc, make], 2, [vrViewer]).
service(userProfiler, [gcc, make], 2, [vrViewer]).

s2s(videoStorage, sceneSelector, 150, 16).
s2s(sceneSelector, videoStorage, 150, 0.5).
s2s(sceneSelector, vrDriver, 20, 8).
s2s(vrDriver, sceneSelector, 20, 1).
s2s(userProfiler, sceneSelector, 50, 2).
s2s(sceneSelector, userProfiler, 50, 2).
s2s(userProfiler, videoStorage, 200, 1).
s2s(videoStorage, userProfiler, 200, 1).

