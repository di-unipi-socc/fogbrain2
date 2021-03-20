:-dynamic node/4.
:-dynamic link/4.
node(cloud0,[ubuntu, mySQL, gcc, make], inf, []).
node(cloud1,[ubuntu, mySQL, gcc, make], inf, []).
node(ispdatacentre0,[ubuntu, mySQL], 50, []).
node(ispdatacentre1,[ubuntu, mySQL], 50, []).
node(cabinetserver0,[ubuntu, mySQL], 20, []).
node(cabinetserver1,[ubuntu, mySQL], 20, []).
node(accesspoint0,[ubuntu, gcc, make], 4, []).
node(accesspoint1,[ubuntu, gcc, make], 4, []).
node(smartphone0,[android, gcc, make], 8, []).
node(smartphone1,[android, gcc, make], 8, []).

link(cloud0, cloud1, 20, 1000).
link(cloud1, cloud0, 20, 1000).
link(cloud0, ispdatacentre0, 110, 1000).
link(cloud0, ispdatacentre1, 110, 1000).
link(cloud1, ispdatacentre0, 110, 1000).
link(cloud1, ispdatacentre1, 110, 1000).
link(cloud0, cabinetserver0, 135, 100).
link(cloud0, cabinetserver1, 135, 100).
link(cloud1, cabinetserver0, 135, 100).
link(cloud1, cabinetserver1, 135, 100).
link(cloud0, accesspoint0,  148, 20).
link(cloud0, accesspoint1,  148, 20).
link(cloud1, accesspoint0,  148, 20).
link(cloud1, accesspoint1,  148, 20).
link(cloud0, smartphone0, 150, 18).
link(cloud0, smartphone1, 150, 18).
link(cloud1, smartphone0, 150, 18).
link(cloud1, smartphone1, 150, 18).

link(ispdatacentre0, cloud0, 110, 1000).
link(ispdatacentre0, cloud1, 110, 1000).
link(ispdatacentre1, cloud0, 110, 1000).
link(ispdatacentre1, cloud1, 110, 1000).
link(ispdatacentre0, ispdatacentre1, 20, 1000).
link(ispdatacentre1, ispdatacentre0, 20, 1000).
link(ispdatacentre0, cabinetserver0, 25, 500).
link(ispdatacentre0, cabinetserver1, 25, 500).
link(ispdatacentre1, cabinetserver0, 25, 500).
link(ispdatacentre1, cabinetserver1, 25, 500).
link(ispdatacentre0, accesspoint0, 38, 50).
link(ispdatacentre0, accesspoint1, 38, 50).
link(ispdatacentre1, accesspoint0, 38, 50).
link(ispdatacentre1, accesspoint1, 38, 50).
link(ispdatacentre0, smartphone0, 20, 1000).
link(ispdatacentre0, smartphone1, 20, 1000).
link(ispdatacentre1, smartphone0, 20, 1000).
link(ispdatacentre1, smartphone1, 20, 1000).

link(cabinetserver0, cloud0, 135, 100).
link(cabinetserver0, cloud1, 135, 100).
link(cabinetserver1, cloud0, 135, 100).
link(cabinetserver1, cloud1, 135, 100).
link(cabinetserver0, ispdatacentre0, 25, 500).
link(cabinetserver0, ispdatacentre1, 25, 500).
link(cabinetserver1, ispdatacentre0, 25, 500).
link(cabinetserver1, ispdatacentre1, 25, 500).
link(cabinetserver0, cabinetserver1, 20, 1000).
link(cabinetserver1, cabinetserver0, 20, 1000).
link(cabinetserver0, accesspoint0, 13, 50).
link(cabinetserver0, accesspoint1, 13, 50).
link(cabinetserver1, accesspoint0, 13, 50).
link(cabinetserver1, accesspoint1, 13, 50).
link(cabinetserver0, smartphone0, 15, 35).
link(cabinetserver0, smartphone1, 15, 35).
link(cabinetserver1, smartphone0, 15, 35).
link(cabinetserver1, smartphone1, 15, 35).

link(accesspoint0, cloud0, 148, 3).
link(accesspoint0, cloud1, 148, 3).
link(accesspoint1, cloud0, 148, 3).
link(accesspoint1, cloud1, 148, 3).
link(accesspoint0, ispdatacentre0, 38, 4).
link(accesspoint0, ispdatacentre1, 38, 4).
link(accesspoint1, ispdatacentre0, 38, 4).
link(accesspoint1, ispdatacentre1, 38, 4).
link(accesspoint0, cabinetserver0, 13, 4).
link(accesspoint0, cabinetserver1, 13, 4).
link(accesspoint1, cabinetserver0, 13, 4).
link(accesspoint1, cabinetserver1, 13, 4).
link(accesspoint0, accesspoint1, 10, 50).
link(accesspoint1, accesspoint0, 10, 50).
link(accesspoint0, smartphone0, 2, 70).
link(accesspoint0, smartphone1, 2, 70).
link(accesspoint1, smartphone0, 2, 70).
link(accesspoint1, smartphone1, 2, 70).

link(smartphone0, cloud0, 150, 2).
link(smartphone0, cloud1, 150, 2).
link(smartphone1, cloud0, 150, 2).
link(smartphone1, cloud1, 150, 2).
link(smartphone0, ispdatacentre0, 40, 2.5).
link(smartphone0, ispdatacentre1, 40, 2.5).
link(smartphone1, ispdatacentre0, 40, 2.5).
link(smartphone1, ispdatacentre1, 40, 2.5).
link(smartphone0, cabinetserver0, 15, 3).
link(smartphone0, cabinetserver1, 15, 3).
link(smartphone1, cabinetserver0, 15, 3).
link(smartphone1, cabinetserver1, 15, 3).
link(smartphone0, accesspoint0, 2, 70).
link(smartphone0, accesspoint1, 2, 70).
link(smartphone1, accesspoint0, 2, 70).
link(smartphone1, accesspoint1, 2, 70).
link(smartphone0, smartphone1, 15, 50).
link(smartphone1, smartphone0, 15, 50).
