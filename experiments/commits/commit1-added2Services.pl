application(vrApp, [videoStorage, sceneSelector, vrDriver, tokensDealer, userProfiler]).

service(videoStorage, [mySQL, ubuntu], 16, []).
service(sceneSelector, [ubuntu], 2, []).
service(vrDriver, [gcc, make], 2, [vrViewer]).
service(tokensDealer, [ubuntu, mySQL], 20, []).
service(userProfiler, [gcc, make], 2, []).

s2s(videoStorage, sceneSelector, 150, 16).
s2s(sceneSelector, videoStorage, 150, 0.5).
s2s(sceneSelector, vrDriver, 20, 8).
s2s(vrDriver, sceneSelector, 20, 1).
s2s(userProfiler, sceneSelector, 50, 2).
s2s(sceneSelector, userProfiler, 50, 2).
s2s(userProfiler, tokensDealer, 200, 0.5).
s2s(tokensDealer, userProfiler, 200, 1).

