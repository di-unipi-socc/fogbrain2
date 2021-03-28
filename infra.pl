node(node0, [], 50, [sensor2]).
node(node1, [ubuntu, mySQL], 20, [sensor1, sensor3]).
node(node2, [ubuntu, mySQL], 20, [sensor1, sensor3]).
node(node3, [ubuntu, mySQL], 50, [sensor2]).
node(node4, [ubuntu, gcc, make], 4, [sensor4, vrViewer]).
node(node5, [ubuntu, mySQL], 25, [sensor2]).
node(node6, [android, gcc, make], 8, [ac, lamp, vrViewer]).
node(node7, [android, gcc, make], 8, [ac, lamp, vrViewer]).
node(node8, [android, gcc, make], 4, [ac, lamp, vrViewer]).
node(node9, [ubuntu, mySQL], 10, [sensor1, sensor3]).
node(node10, [], 20, [sensor1, sensor3]).
node(node11, [ubuntu, mySQL], 20, [sensor1, sensor3]).
node(node12, [ubuntu, mySQL], 50, [sensor2]).
node(node13, [ubuntu], 4, [sensor4, vrViewer]).
node(node14, [ubuntu, mySQL], 50, [sensor2]).
node(node15, [ubuntu, mySQL], 50, [sensor2]).
link(node0, node4, 5, 2).
link(node4, node0, 5, 2).
link(node0, node5, 200, 100).
link(node5, node0, 200, 100).
link(node0, node6, 100, 7).
link(node6, node0, 100, 7).
link(node0, node10, 50, 500).
link(node10, node0, 50, 500).
link(node0, node12, 150, 20).
link(node12, node0, 150, 20).
link(node0, node13, 150, 500).
link(node13, node0, 150, 500).
link(node0, node14, 100, 7).
link(node14, node0, 100, 7).
link(node1, node4, 5, 2).
link(node4, node1, 5, 2).
link(node1, node5, 150, 500).
link(node5, node1, 150, 500).
link(node1, node6, 5, 100).
link(node6, node1, 5, 100).
link(node1, node7, 150, 100).
link(node7, node1, 150, 100).
link(node1, node10, 50, 50).
link(node10, node1, 50, 50).
link(node1, node11, 10, 20).
link(node11, node1, 10, 20).
link(node1, node13, 10, 7).
link(node13, node1, 10, 7).
link(node2, node4, 10, 100).
link(node4, node2, 10, 100).
link(node2, node5, 50, 7).
link(node5, node2, 50, 7).
link(node2, node7, 10, 100).
link(node7, node2, 10, 100).
link(node2, node14, 5, 500).
link(node14, node2, 5, 500).
link(node2, node15, 50, 500).
link(node15, node2, 50, 500).
link(node3, node4, 50, 500).
link(node4, node3, 50, 500).
link(node3, node7, 200, 500).
link(node7, node3, 200, 500).
link(node3, node11, 10, 100).
link(node11, node3, 10, 100).
link(node4, node5, 200, 100).
link(node5, node4, 200, 100).
link(node4, node6, 10, 2).
link(node6, node4, 10, 2).
link(node4, node8, 50, 7).
link(node8, node4, 50, 7).
link(node4, node9, 10, 2).
link(node9, node4, 10, 2).
link(node4, node10, 200, 100).
link(node10, node4, 200, 100).
link(node4, node11, 150, 100).
link(node11, node4, 150, 100).
link(node5, node6, 5, 20).
link(node6, node5, 5, 20).
link(node5, node8, 100, 20).
link(node8, node5, 100, 20).
link(node5, node9, 10, 7).
link(node9, node5, 10, 7).
link(node5, node12, 100, 500).
link(node12, node5, 100, 500).
link(node6, node7, 5, 20).
link(node7, node6, 5, 20).
link(node6, node8, 200, 20).
link(node8, node6, 200, 20).
link(node6, node9, 100, 2).
link(node9, node6, 100, 2).
link(node6, node10, 5, 20).
link(node10, node6, 5, 20).
link(node7, node8, 5, 2).
link(node8, node7, 5, 2).
link(node7, node9, 50, 2).
link(node9, node7, 50, 2).
link(node8, node11, 10, 2).
link(node11, node8, 10, 2).
link(node8, node12, 25, 100).
link(node12, node8, 25, 100).
link(node8, node15, 10, 100).
link(node15, node8, 10, 100).
link(node10, node13, 200, 7).
link(node13, node10, 200, 7).
link(node10, node15, 10, 500).
link(node15, node10, 10, 500).
link(node11, node12, 200, 7).
link(node12, node11, 200, 7).
link(node11, node14, 10, 2).
link(node14, node11, 10, 2).
link(node12, node13, 10, 2).
link(node13, node12, 10, 2).
link(node12, node14, 10, 2).
link(node14, node12, 10, 2).
link(node14, node15, 200, 500).
link(node15, node14, 200, 500).
