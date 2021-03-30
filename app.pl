application(vrApp, [sceneSelector, vrDriver, s]).

service(sceneSelector, [ubuntu], 2, []).
service(vrDriver, [gcc, make], 2, [vrViewer]).
service(s, [], 1, []).

s2s(sceneSelector, vrDriver, 20, 8).
s2s(vrDriver, sceneSelector, 20, 1).
s2s(s, vrDriver, 100, 2).

