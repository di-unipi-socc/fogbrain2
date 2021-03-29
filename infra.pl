node(node0, [ubuntu], 50, [sensor2]).
node(node1, [ubuntu, mySQL], 20, [sensor1, sensor3]).
node(node2, [ubuntu, mySQL], 0, [sensor1, sensor3]).
node(node3, [ubuntu, mySQL], 0, [sensor2]).
node(node4, [ubuntu, mySQL], 20, [sensor1, sensor3]).
node(node5, [android, gcc, make], 0, [ac, lamp]).
node(node6, [], 20, [sensor1, sensor3]).
node(node7, [ubuntu], 50, [sensor2]).
node(node8, [ubuntu], 20, [sensor1, sensor3]).
node(node9, [android, gcc, make], 8, [ac, lamp]).
node(node10, [], inf, [sensor1, sensor2, sensor3]).
node(node11, [], 20, [sensor1, sensor3]).
node(node12, [ubuntu, mySQL], 50, [sensor2]).
node(node13, [ubuntu, mySQL], 20, [sensor1, sensor3]).
node(node14, [ubuntu], inf, [sensor1, sensor2, sensor3]).
node(node15, [], 4, [sensor4]).
link(node0, node2, 200, 100).
link(node2, node0, 200, 100).
link(node0, node3, 150, 500).
link(node3, node0, 150, 500).
link(node0, node6, 25, 100).
link(node6, node0, 25, 100).
link(node0, node7, 10, 50).
link(node7, node0, 10, 50).
link(node0, node14, 200, 2).
link(node14, node0, 200, 2).
link(node1, node2, 150, 7).
link(node2, node1, 150, 7).
link(node1, node11, 5, 100).
link(node11, node1, 5, 100).
link(node1, node12, 25, 20).
link(node12, node1, 25, 20).
link(node1, node13, 50, 50).
link(node13, node1, 50, 50).
link(node1, node15, 150, 100).
link(node15, node1, 150, 100).
link(node2, node3, 5, 2).
link(node3, node2, 5, 2).
link(node2, node4, 50, 2).
link(node4, node2, 50, 2).
link(node2, node10, 10, 50).
link(node10, node2, 10, 50).
link(node2, node12, 100, 500).
link(node12, node2, 100, 500).
link(node2, node14, 25, 50).
link(node14, node2, 25, 50).
link(node3, node4, 200, 7).
link(node4, node3, 200, 7).
link(node3, node5, 25, 20).
link(node5, node3, 25, 20).
link(node3, node6, 5, 500).
link(node6, node3, 5, 500).
link(node3, node9, 5, 2).
link(node9, node3, 5, 2).
link(node3, node13, 5, 50).
link(node13, node3, 5, 50).
link(node4, node5, 100, 2).
link(node5, node4, 100, 2).
link(node4, node7, 150, 500).
link(node7, node4, 150, 500).
link(node4, node9, 5, 500).
link(node9, node4, 5, 500).
link(node5, node8, 10, 50).
link(node8, node5, 10, 50).
link(node6, node8, 5, 50).
link(node8, node6, 5, 50).
link(node7, node10, 50, 50).
link(node10, node7, 50, 50).
link(node8, node11, 150, 500).
link(node11, node8, 150, 500).
link(node10, node15, 100, 50).
link(node15, node10, 100, 50).
