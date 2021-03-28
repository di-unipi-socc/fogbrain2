node(node0, [ubuntu, mySQL], 20, [sensor1, sensor3]).
node(node1, [ubuntu, mySQL], 10, [sensor1, sensor3]).
node(node2, [ubuntu, mySQL, gcc, make], inf, [sensor1, sensor2, sensor3]).
node(node3, [ubuntu, mySQL], 10, [sensor1, sensor3]).
node(node4, [], 8, [ac, lamp]).
node(node5, [ubuntu, mySQL], 25, [sensor2]).
node(node6, [ubuntu], 25, [sensor2]).
node(node7, [android, gcc, make], 8, [ac, lamp]).
node(node8, [], 8, [ac, lamp]).
node(node9, [ubuntu, gcc, make], 0, [sensor4]).
node(node10, [ubuntu, mySQL], 10, [sensor1, sensor3]).
node(node11, [android], 8, [ac, lamp]).
node(node12, [ubuntu, mySQL], 50, [sensor2]).
node(node13, [android, gcc, make], 0, [ac, lamp]).
node(node14, [ubuntu, gcc, make], 0, [sensor4]).
node(node15, [ubuntu, mySQL], 10, [sensor1, sensor3]).
link(node0, node4, 5, 7).
link(node4, node0, 5, 7).
link(node0, node5, 100, 2).
link(node5, node0, 100, 2).
link(node0, node6, 5, 100).
link(node6, node0, 5, 100).
link(node0, node9, 10, 7).
link(node9, node0, 10, 7).
link(node0, node12, 5, 2).
link(node12, node0, 5, 2).
link(node1, node4, 100, 7).
link(node4, node1, 100, 7).
link(node1, node5, 150, 20).
link(node5, node1, 150, 20).
link(node1, node6, 10, 20).
link(node6, node1, 10, 20).
link(node1, node7, 10, 100).
link(node7, node1, 10, 100).
link(node1, node9, 5, 500).
link(node9, node1, 5, 500).
link(node1, node11, 150, 20).
link(node11, node1, 150, 20).
link(node2, node4, 50, 20).
link(node4, node2, 50, 20).
link(node2, node5, 200, 7).
link(node5, node2, 200, 7).
link(node2, node7, 10, 500).
link(node7, node2, 10, 500).
link(node2, node8, 50, 50).
link(node8, node2, 50, 50).
link(node2, node9, 150, 7).
link(node9, node2, 150, 7).
link(node2, node12, 200, 2).
link(node12, node2, 200, 2).
link(node2, node15, 150, 50).
link(node15, node2, 150, 50).
link(node3, node4, 10, 20).
link(node4, node3, 10, 20).
link(node3, node10, 150, 50).
link(node10, node3, 150, 50).
link(node3, node11, 50, 2).
link(node11, node3, 50, 2).
link(node3, node12, 100, 50).
link(node12, node3, 100, 50).
link(node3, node14, 25, 50).
link(node14, node3, 25, 50).
link(node4, node5, 50, 2).
link(node5, node4, 50, 2).
link(node4, node6, 150, 20).
link(node6, node4, 150, 20).
link(node4, node7, 200, 50).
link(node7, node4, 200, 50).
link(node4, node10, 50, 500).
link(node10, node4, 50, 500).
link(node4, node11, 50, 20).
link(node11, node4, 50, 20).
link(node4, node12, 10, 7).
link(node12, node4, 10, 7).
link(node4, node13, 150, 2).
link(node13, node4, 150, 2).
link(node4, node15, 50, 20).
link(node15, node4, 50, 20).
link(node5, node6, 200, 7).
link(node6, node5, 200, 7).
link(node5, node7, 5, 500).
link(node7, node5, 5, 500).
link(node5, node8, 150, 7).
link(node8, node5, 150, 7).
link(node5, node10, 5, 100).
link(node10, node5, 5, 100).
link(node5, node14, 200, 7).
link(node14, node5, 200, 7).
link(node5, node15, 5, 2).
link(node15, node5, 5, 2).
link(node6, node8, 200, 100).
link(node8, node6, 200, 100).
link(node6, node11, 25, 500).
link(node11, node6, 25, 500).
link(node7, node8, 50, 50).
link(node8, node7, 50, 50).
link(node8, node9, 200, 2).
link(node9, node8, 200, 2).
link(node9, node10, 150, 20).
link(node10, node9, 150, 20).
link(node10, node13, 10, 50).
link(node13, node10, 10, 50).
link(node11, node13, 25, 50).
link(node13, node11, 25, 50).
link(node11, node15, 50, 20).
link(node15, node11, 50, 20).
link(node12, node13, 150, 2).
link(node13, node12, 150, 2).
link(node12, node14, 200, 7).
link(node14, node12, 200, 7).
link(node13, node14, 25, 100).
link(node14, node13, 25, 100).
