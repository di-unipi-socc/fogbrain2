node(cloud1,[ubuntu, mySQL, gcc, make], inf, []).
node(cloud2,[ubuntu, mySQL, gcc, make], inf, []).
node(ispdatacentre0,[ubuntu, mySQL], 50, []).
node(ispdatacentre1,[ubuntu, mySQL], 50, []).
node(ispdatacentre2,[ubuntu, mySQL], 50, []).
node(cabinetserver0,[ubuntu, mySQL], 20, []).
node(cabinetserver1,[ubuntu, mySQL], 20, []).
node(cabinetserver2,[ubuntu, mySQL], 20, []).
node(accesspoint0,[ubuntu, gcc, make], 4, [vrViewer]).
node(accesspoint1,[ubuntu, gcc, make], 4, [vrViewer]).
node(accesspoint2,[ubuntu, gcc, make], 4, [vrViewer]).
node(smartphone0,[android, gcc, make], 8, [vrViewer]).
node(smartphone1,[android, gcc, make], 8, [vrViewer]).
node(smartphone2,[android, gcc, make], 8, [vrViewer]).

link(cloud1, cloud2, 20, 1000).
link(cloud2, cloud1, 20, 1000).
link(cloud1, ispdatacentre0, 110, 1000).
link(cloud1, ispdatacentre1, 110, 1000).
link(cloud1, ispdatacentre2, 110, 1000).
link(cloud2, ispdatacentre0, 110, 1000).
link(cloud2, ispdatacentre1, 110, 1000).
link(cloud2, ispdatacentre2, 110, 1000).
link(cloud1, cabinetserver0, 135, 100).
link(cloud1, cabinetserver1, 135, 100).
link(cloud1, cabinetserver2, 135, 100).
link(cloud2, cabinetserver0, 135, 100).
link(cloud2, cabinetserver1, 135, 100).
link(cloud2, cabinetserver2, 135, 100).
link(cloud1, accesspoint0,  148, 20).
link(cloud1, accesspoint1,  148, 20).
link(cloud1, accesspoint2,  148, 20).
link(cloud2, accesspoint0,  148, 20).
link(cloud2, accesspoint1,  148, 20).
link(cloud2, accesspoint2,  148, 20).
link(cloud1, smartphone0, 150, 18).
link(cloud1, smartphone1, 150, 18).
link(cloud1, smartphone2, 150, 18).
link(cloud2, smartphone0, 150, 18).
link(cloud2, smartphone1, 150, 18).
link(cloud2, smartphone2, 150, 18).

link(ispdatacentre0, cloud1, 110, 1000).
link(ispdatacentre0, cloud2, 110, 1000).
link(ispdatacentre1, cloud1, 110, 1000).
link(ispdatacentre1, cloud2, 110, 1000).
link(ispdatacentre2, cloud1, 110, 1000).
link(ispdatacentre2, cloud2, 110, 1000).
link(ispdatacentre0, ispdatacentre1, 20, 1000).
link(ispdatacentre0, ispdatacentre2, 20, 1000).
link(ispdatacentre1, ispdatacentre0, 20, 1000).
link(ispdatacentre1, ispdatacentre2, 20, 1000).
link(ispdatacentre2, ispdatacentre0, 20, 1000).
link(ispdatacentre2, ispdatacentre1, 20, 1000).
link(ispdatacentre0, cabinetserver0, 25, 500).
link(ispdatacentre0, cabinetserver1, 25, 500).
link(ispdatacentre0, cabinetserver2, 25, 500).
link(ispdatacentre1, cabinetserver0, 25, 500).
link(ispdatacentre1, cabinetserver1, 25, 500).
link(ispdatacentre1, cabinetserver2, 25, 500).
link(ispdatacentre2, cabinetserver0, 25, 500).
link(ispdatacentre2, cabinetserver1, 25, 500).
link(ispdatacentre2, cabinetserver2, 25, 500).
link(ispdatacentre0, accesspoint0, 38, 50).
link(ispdatacentre0, accesspoint1, 38, 50).
link(ispdatacentre0, accesspoint2, 38, 50).
link(ispdatacentre1, accesspoint0, 38, 50).
link(ispdatacentre1, accesspoint1, 38, 50).
link(ispdatacentre1, accesspoint2, 38, 50).
link(ispdatacentre2, accesspoint0, 38, 50).
link(ispdatacentre2, accesspoint1, 38, 50).
link(ispdatacentre2, accesspoint2, 38, 50).
link(ispdatacentre0, smartphone0, 20, 1000).
link(ispdatacentre0, smartphone1, 20, 1000).
link(ispdatacentre0, smartphone2, 20, 1000).
link(ispdatacentre1, smartphone0, 20, 1000).
link(ispdatacentre1, smartphone1, 20, 1000).
link(ispdatacentre1, smartphone2, 20, 1000).
link(ispdatacentre2, smartphone0, 20, 1000).
link(ispdatacentre2, smartphone1, 20, 1000).
link(ispdatacentre2, smartphone2, 20, 1000).

link(cabinetserver0, cloud1, 135, 100).
link(cabinetserver0, cloud2, 135, 100).
link(cabinetserver1, cloud1, 135, 100).
link(cabinetserver1, cloud2, 135, 100).
link(cabinetserver2, cloud1, 135, 100).
link(cabinetserver2, cloud2, 135, 100).
link(cabinetserver0, ispdatacentre0, 25, 500).
link(cabinetserver0, ispdatacentre1, 25, 500).
link(cabinetserver0, ispdatacentre2, 25, 500).
link(cabinetserver1, ispdatacentre0, 25, 500).
link(cabinetserver1, ispdatacentre1, 25, 500).
link(cabinetserver1, ispdatacentre2, 25, 500).
link(cabinetserver2, ispdatacentre0, 25, 500).
link(cabinetserver2, ispdatacentre1, 25, 500).
link(cabinetserver2, ispdatacentre2, 25, 500).
link(cabinetserver0, cabinetserver1, 20, 1000).
link(cabinetserver0, cabinetserver2, 20, 1000).
link(cabinetserver1, cabinetserver0, 20, 1000).
link(cabinetserver1, cabinetserver2, 20, 1000).
link(cabinetserver2, cabinetserver0, 20, 1000).
link(cabinetserver2, cabinetserver1, 20, 1000).
link(cabinetserver0, accesspoint0, 13, 50).
link(cabinetserver0, accesspoint1, 13, 50).
link(cabinetserver0, accesspoint2, 13, 50).
link(cabinetserver1, accesspoint0, 13, 50).
link(cabinetserver1, accesspoint1, 13, 50).
link(cabinetserver1, accesspoint2, 13, 50).
link(cabinetserver2, accesspoint0, 13, 50).
link(cabinetserver2, accesspoint1, 13, 50).
link(cabinetserver2, accesspoint2, 13, 50).
link(cabinetserver0, smartphone0, 15, 35).
link(cabinetserver0, smartphone1, 15, 35).
link(cabinetserver0, smartphone2, 15, 35).
link(cabinetserver1, smartphone0, 15, 35).
link(cabinetserver1, smartphone1, 15, 35).
link(cabinetserver1, smartphone2, 15, 35).
link(cabinetserver2, smartphone0, 15, 35).
link(cabinetserver2, smartphone1, 15, 35).
link(cabinetserver2, smartphone2, 15, 35).

link(accesspoint0, cloud1, 148, 3).
link(accesspoint0, cloud2, 148, 3).
link(accesspoint1, cloud1, 148, 3).
link(accesspoint1, cloud2, 148, 3).
link(accesspoint2, cloud1, 148, 3).
link(accesspoint2, cloud2, 148, 3).
link(accesspoint0, ispdatacentre0, 38, 4).
link(accesspoint0, ispdatacentre1, 38, 4).
link(accesspoint0, ispdatacentre2, 38, 4).
link(accesspoint1, ispdatacentre0, 38, 4).
link(accesspoint1, ispdatacentre1, 38, 4).
link(accesspoint1, ispdatacentre2, 38, 4).
link(accesspoint2, ispdatacentre0, 38, 4).
link(accesspoint2, ispdatacentre1, 38, 4).
link(accesspoint2, ispdatacentre2, 38, 4).
link(accesspoint0, cabinetserver0, 13, 4).
link(accesspoint0, cabinetserver1, 13, 4).
link(accesspoint0, cabinetserver2, 13, 4).
link(accesspoint1, cabinetserver0, 13, 4).
link(accesspoint1, cabinetserver1, 13, 4).
link(accesspoint1, cabinetserver2, 13, 4).
link(accesspoint2, cabinetserver0, 13, 4).
link(accesspoint2, cabinetserver1, 13, 4).
link(accesspoint2, cabinetserver2, 13, 4).
link(accesspoint0, accesspoint1, 10, 50).
link(accesspoint0, accesspoint2, 10, 50).
link(accesspoint1, accesspoint0, 10, 50).
link(accesspoint1, accesspoint2, 10, 50).
link(accesspoint2, accesspoint0, 10, 50).
link(accesspoint2, accesspoint1, 10, 50).
link(accesspoint0, smartphone0, 2, 70).
link(accesspoint0, smartphone1, 2, 70).
link(accesspoint0, smartphone2, 2, 70).
link(accesspoint1, smartphone0, 2, 70).
link(accesspoint1, smartphone1, 2, 70).
link(accesspoint1, smartphone2, 2, 70).
link(accesspoint2, smartphone0, 2, 70).
link(accesspoint2, smartphone1, 2, 70).
link(accesspoint2, smartphone2, 2, 70).

link(smartphone0, cloud1, 150, 2).
link(smartphone0, cloud2, 150, 2).
link(smartphone1, cloud1, 150, 2).
link(smartphone1, cloud2, 150, 2).
link(smartphone2, cloud1, 150, 2).
link(smartphone2, cloud2, 150, 2).
link(smartphone0, ispdatacentre0, 40, 2.5).
link(smartphone0, ispdatacentre1, 40, 2.5).
link(smartphone0, ispdatacentre2, 40, 2.5).
link(smartphone1, ispdatacentre0, 40, 2.5).
link(smartphone1, ispdatacentre1, 40, 2.5).
link(smartphone1, ispdatacentre2, 40, 2.5).
link(smartphone2, ispdatacentre0, 40, 2.5).
link(smartphone2, ispdatacentre1, 40, 2.5).
link(smartphone2, ispdatacentre2, 40, 2.5).
link(smartphone0, cabinetserver0, 15, 3).
link(smartphone0, cabinetserver1, 15, 3).
link(smartphone0, cabinetserver2, 15, 3).
link(smartphone1, cabinetserver0, 15, 3).
link(smartphone1, cabinetserver1, 15, 3).
link(smartphone1, cabinetserver2, 15, 3).
link(smartphone2, cabinetserver0, 15, 3).
link(smartphone2, cabinetserver1, 15, 3).
link(smartphone2, cabinetserver2, 15, 3).
link(smartphone0, accesspoint0, 2, 70).
link(smartphone0, accesspoint1, 2, 70).
link(smartphone0, accesspoint2, 2, 70).
link(smartphone1, accesspoint0, 2, 70).
link(smartphone1, accesspoint1, 2, 70).
link(smartphone1, accesspoint2, 2, 70).
link(smartphone2, accesspoint0, 2, 70).
link(smartphone2, accesspoint1, 2, 70).
link(smartphone2, accesspoint2, 2, 70).
link(smartphone0, smartphone1, 15, 50).
link(smartphone0, smartphone2, 15, 50).
link(smartphone1, smartphone0, 15, 50).
link(smartphone1, smartphone2, 15, 50).
link(smartphone2, smartphone0, 15, 50).
link(smartphone2, smartphone1, 15, 50).