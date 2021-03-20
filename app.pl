application(vrApp, [sceneSelector, vrDriver]).

service(sceneSelector, [ubuntu, gcc, make], 1, [vrViewer]).
service(vrDriver, [gcc, make], 2, [vrViewer]).

s2s(sceneSelector, vrDriver, 20, 8).
s2s(vrDriver, sceneSelector, 20, 1).

