%application(vrApp, [vrDriver, videoStorage, sceneSelector]).
application(vrApp, [vrDriver, sceneSelector]).

%service(videoStorage, [mySQL, ubuntu], 16, []).
service(sceneSelector, [ubuntu], 2, []).
service(vrDriver, [gcc, make], 2, [vrViewer]).

%s2s(videoStorage, sceneSelector, 150, 101).
%s2s(sceneSelector, videoStorage, 150, 0.5).
s2s(sceneSelector, vrDriver, 20, 8).
s2s(vrDriver, sceneSelector, 20, 1).
