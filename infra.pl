node(node0, [ubuntu, mySQL], 20, [sensor1, sensor3]).
node(node1, [], 25, [sensor2]).
node(node2, [ubuntu, mySQL], 50, [sensor2]).
node(node3, [ubuntu, gcc, make], 4, [sensor4]).
node(node4, [ubuntu, mySQL], 20, [sensor1, sensor3]).
node(node5, [ubuntu, mySQL], 50, [sensor2]).
node(node6, [], 10, [sensor1, sensor3]).
node(node7, [ubuntu, mySQL, gcc, make], 0, [sensor1, sensor2, sensor3]).
node(node8, [ubuntu], 25, [sensor2]).
node(node9, [ubuntu, gcc, make], 4, [sensor4]).
node(node10, [ubuntu, mySQL], 0, [sensor1, sensor3]).
node(node11, [ubuntu, mySQL], 0, [sensor2]).
node(node12, [ubuntu, mySQL], 20, [sensor1, sensor3]).
node(node13, [android, gcc, make], 0, [ac, lamp]).
node(node14, [], 20, [sensor1, sensor3]).
node(node15, [ubuntu], 50, [sensor2]).
link(node0, node1, 50, 10).
link(node1, node0, 50, 10).
link(node0, node2, 100, 10).
link(node2, node0, 100, 10).
link(node0, node3, 25, 100).
link(node3, node0, 25, 100).
link(node0, node4, 5, 500).
link(node4, node0, 5, 500).
link(node0, node5, 25, 500).
link(node5, node0, 25, 500).
link(node0, node6, 10, 10).
link(node6, node0, 10, 10).
link(node0, node7, 25, 100).
link(node7, node0, 25, 100).
link(node0, node8, 100, 500).
link(node8, node0, 100, 500).
link(node0, node9, 100, 10).
link(node9, node0, 100, 10).
link(node0, node10, 25, 10).
link(node10, node0, 25, 10).
link(node0, node11, 50, 500).
link(node11, node0, 50, 500).
link(node0, node12, 5, 50).
link(node12, node0, 5, 50).
link(node0, node13, 150, 10).
link(node13, node0, 150, 10).
link(node0, node14, 50, 20).
link(node14, node0, 50, 20).
link(node0, node15, 10, 500).
link(node15, node0, 10, 500).
link(node1, node2, 50, 20).
link(node2, node1, 50, 20).
link(node1, node3, 25, 500).
link(node3, node1, 25, 500).
link(node1, node4, 150, 50).
link(node4, node1, 150, 50).
link(node1, node5, 100, 20).
link(node5, node1, 100, 20).
link(node1, node6, 50, 10).
link(node6, node1, 50, 10).
link(node1, node7, 150, 20).
link(node7, node1, 150, 20).
link(node1, node8, 5, 500).
link(node8, node1, 5, 500).
link(node1, node9, 25, 50).
link(node9, node1, 25, 50).
link(node1, node10, 50, 100).
link(node10, node1, 50, 100).
link(node1, node11, 150, 500).
link(node11, node1, 150, 500).
link(node1, node12, 5, 10).
link(node12, node1, 5, 10).
link(node1, node13, 50, 10).
link(node13, node1, 50, 10).
link(node1, node14, 10, 100).
link(node14, node1, 10, 100).
link(node1, node15, 100, 50).
link(node15, node1, 100, 50).
link(node2, node3, 50, 20).
link(node3, node2, 50, 20).
link(node2, node4, 25, 50).
link(node4, node2, 25, 50).
link(node2, node5, 5, 10).
link(node5, node2, 5, 10).
link(node2, node6, 5, 10).
link(node6, node2, 5, 10).
link(node2, node7, 50, 500).
link(node7, node2, 50, 500).
link(node2, node8, 5, 10).
link(node8, node2, 5, 10).
link(node2, node9, 150, 20).
link(node9, node2, 150, 20).
link(node2, node10, 50, 10).
link(node10, node2, 50, 10).
link(node2, node11, 50, 100).
link(node11, node2, 50, 100).
link(node2, node12, 50, 500).
link(node12, node2, 50, 500).
link(node2, node13, 50, 500).
link(node13, node2, 50, 500).
link(node2, node14, 150, 10).
link(node14, node2, 150, 10).
link(node2, node15, 50, 10).
link(node15, node2, 50, 10).
link(node3, node4, 25, 100).
link(node4, node3, 25, 100).
link(node3, node5, 10, 500).
link(node5, node3, 10, 500).
link(node3, node6, 5, 500).
link(node6, node3, 5, 500).
link(node3, node7, 50, 500).
link(node7, node3, 50, 500).
link(node3, node8, 10, 50).
link(node8, node3, 10, 50).
link(node3, node9, 5, 500).
link(node9, node3, 5, 500).
link(node3, node10, 150, 10).
link(node10, node3, 150, 10).
link(node3, node11, 10, 100).
link(node11, node3, 10, 100).
link(node3, node12, 150, 50).
link(node12, node3, 150, 50).
link(node3, node13, 50, 50).
link(node13, node3, 50, 50).
link(node3, node14, 150, 50).
link(node14, node3, 150, 50).
link(node3, node15, 10, 50).
link(node15, node3, 10, 50).
link(node4, node5, 50, 100).
link(node5, node4, 50, 100).
link(node4, node6, 100, 100).
link(node6, node4, 100, 100).
link(node4, node7, 25, 20).
link(node7, node4, 25, 20).
link(node4, node8, 5, 500).
link(node8, node4, 5, 500).
link(node4, node9, 10, 10).
link(node9, node4, 10, 10).
link(node4, node10, 150, 50).
link(node10, node4, 150, 50).
link(node4, node11, 10, 50).
link(node11, node4, 10, 50).
link(node4, node12, 10, 10).
link(node12, node4, 10, 10).
link(node4, node13, 25, 50).
link(node13, node4, 25, 50).
link(node4, node14, 50, 50).
link(node14, node4, 50, 50).
link(node4, node15, 25, 50).
link(node15, node4, 25, 50).
link(node5, node6, 150, 50).
link(node6, node5, 150, 50).
link(node5, node7, 25, 100).
link(node7, node5, 25, 100).
link(node5, node8, 10, 10).
link(node8, node5, 10, 10).
link(node5, node9, 100, 50).
link(node9, node5, 100, 50).
link(node5, node10, 25, 100).
link(node10, node5, 25, 100).
link(node5, node11, 100, 20).
link(node11, node5, 100, 20).
link(node5, node12, 150, 20).
link(node12, node5, 150, 20).
link(node5, node13, 50, 500).
link(node13, node5, 50, 500).
link(node5, node14, 10, 20).
link(node14, node5, 10, 20).
link(node5, node15, 25, 500).
link(node15, node5, 25, 500).
link(node6, node7, 100, 20).
link(node7, node6, 100, 20).
link(node6, node8, 100, 500).
link(node8, node6, 100, 500).
link(node6, node9, 50, 10).
link(node9, node6, 50, 10).
link(node6, node10, 150, 50).
link(node10, node6, 150, 50).
link(node6, node11, 10, 500).
link(node11, node6, 10, 500).
link(node6, node12, 50, 10).
link(node12, node6, 50, 10).
link(node6, node13, 50, 20).
link(node13, node6, 50, 20).
link(node6, node14, 50, 10).
link(node14, node6, 50, 10).
link(node6, node15, 150, 10).
link(node15, node6, 150, 10).
link(node7, node8, 5, 100).
link(node8, node7, 5, 100).
link(node7, node9, 25, 10).
link(node9, node7, 25, 10).
link(node7, node10, 100, 100).
link(node10, node7, 100, 100).
link(node7, node11, 50, 50).
link(node11, node7, 50, 50).
link(node7, node12, 50, 50).
link(node12, node7, 50, 50).
link(node7, node13, 10, 50).
link(node13, node7, 10, 50).
link(node7, node14, 100, 20).
link(node14, node7, 100, 20).
link(node7, node15, 100, 20).
link(node15, node7, 100, 20).
link(node8, node9, 25, 10).
link(node9, node8, 25, 10).
link(node8, node10, 25, 20).
link(node10, node8, 25, 20).
link(node8, node11, 150, 20).
link(node11, node8, 150, 20).
link(node8, node12, 5, 50).
link(node12, node8, 5, 50).
link(node8, node13, 100, 20).
link(node13, node8, 100, 20).
link(node8, node14, 25, 100).
link(node14, node8, 25, 100).
link(node8, node15, 100, 20).
link(node15, node8, 100, 20).
link(node9, node10, 5, 20).
link(node10, node9, 5, 20).
link(node9, node11, 150, 50).
link(node11, node9, 150, 50).
link(node9, node12, 25, 10).
link(node12, node9, 25, 10).
link(node9, node13, 25, 50).
link(node13, node9, 25, 50).
link(node9, node14, 5, 50).
link(node14, node9, 5, 50).
link(node9, node15, 10, 50).
link(node15, node9, 10, 50).
link(node10, node11, 5, 100).
link(node11, node10, 5, 100).
link(node10, node12, 5, 500).
link(node12, node10, 5, 500).
link(node10, node13, 10, 50).
link(node13, node10, 10, 50).
link(node10, node14, 5, 20).
link(node14, node10, 5, 20).
link(node10, node15, 25, 100).
link(node15, node10, 25, 100).
link(node11, node12, 100, 20).
link(node12, node11, 100, 20).
link(node11, node13, 150, 20).
link(node13, node11, 150, 20).
link(node11, node14, 100, 100).
link(node14, node11, 100, 100).
link(node11, node15, 5, 100).
link(node15, node11, 5, 100).
link(node12, node13, 100, 50).
link(node13, node12, 100, 50).
link(node12, node14, 10, 10).
link(node14, node12, 10, 10).
link(node12, node15, 5, 100).
link(node15, node12, 5, 100).
link(node13, node14, 50, 10).
link(node14, node13, 50, 10).
link(node13, node15, 10, 100).
link(node15, node13, 10, 100).
link(node14, node15, 5, 100).
link(node15, node14, 5, 100).
