node(cloud, [ubuntu, mySQL, gcc, make], inf, []).
node(ispdatacentre, [ubuntu, mySQL], 50, []).
node(cabinetserver, [ubuntu, mySQL], 20, []).
node(accesspoint, [ubuntu, gcc, make], 4, [vrViewer]).
node(smartphone, [android, gcc, make], 8, [vrViewer]).

link(cloud, ispdatacentre, 110, 1000).
link(cloud, cabinetserver, 135, 100).
link(cloud, accesspoint, 148, 20).
link(cloud, smartphone, 150, 18).
link(ispdatacentre, cloud, 110, 1000).
link(ispdatacentre, cabinetserver, 25, 500).
link(ispdatacentre, accesspoint, 38, 50).
link(ispdatacentre, smartphone, 40, 35).
link(cabinetserver, cloud, 135, 100).
link(cabinetserver, ispdatacentre, 25, 500).
link(cabinetserver, accesspoint, 13, 50).
link(cabinetserver, smartphone, 15, 35).
link(accesspoint, cloud, 148, 3).
link(accesspoint, ispdatacentre, 38, 4).
link(accesspoint, cabinetserver, 13, 4).
link(accesspoint, smartphone, 2, 70).
link(smartphone, cloud, 150, 2).
link(smartphone, ispdatacentre, 40, 2.5).
link(smartphone, cabinetserver, 15, 3).
link(smartphone, accesspoint, 2, 70).

