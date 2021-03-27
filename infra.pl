node(node0, [ubuntu, mySQL], 0, []).
node(node1, [], 10, []).
node(node2, [ubuntu, mySQL], 0, []).
node(node3, [ubuntu, mySQL], 50, []).
node(node4, [android, gcc, make], 8, [vrViewer]).
node(node5, [ubuntu, gcc, make], 2, []).
node(node6, [ubuntu], inf, []).
node(node7, [android, gcc, make], 4, [vrViewer]).
node(node8, [ubuntu, mySQL], 25, []).
node(node9, [android, gcc, make], 8, []).
node(node10, [ubuntu, mySQL, gcc, make], inf, []).
node(node11, [ubuntu, gcc, make], 4, []).
node(node12, [ubuntu, gcc, make], 0, []).
node(node13, [], 10, []).
node(node14, [ubuntu, gcc, make], 2, []).
node(node15, [ubuntu, mySQL], 50, []).
link(node0, node4, 100, 7).
link(node0, node5, 50, 7).
link(node0, node6, 25, 500).
link(node0, node8, 5, 50).
link(node0, node10, 100, 100).
link(node0, node11, 100, 500).
link(node0, node14, 25, 2).
link(node1, node4, 10, 500).
link(node1, node5, 5, 500).
link(node1, node6, 25, 100).
link(node1, node7, 25, 100).
link(node1, node8, 200, 100).
link(node1, node9, 100, 50).
link(node1, node10, 50, 7).
link(node1, node12, 50, 500).
link(node1, node15, 50, 7).
link(node2, node4, 5, 2).
link(node2, node5, 200, 50).
link(node2, node8, 100, 2).
link(node2, node12, 100, 20).
link(node3, node4, 5, 500).
link(node3, node7, 5, 20).
link(node3, node11, 25, 7).
link(node3, node13, 50, 7).
link(node3, node15, 50, 2).
link(node4, node5, 150, 2).
link(node4, node6, 25, 2).
link(node4, node7, 150, 500).
link(node4, node9, 25, 20).
link(node4, node10, 100, 500).
link(node4, node13, 100, 500).
link(node4, node15, 150, 2).
link(node5, node6, 10, 50).
link(node5, node7, 5, 500).
link(node5, node8, 10, 50).
link(node5, node13, 200, 20).
link(node5, node14, 5, 2).
link(node7, node9, 200, 20).
link(node7, node11, 50, 2).
link(node7, node13, 10, 20).
link(node7, node14, 10, 7).
link(node8, node9, 10, 50).
link(node8, node10, 100, 500).
link(node8, node11, 10, 500).
link(node9, node12, 200, 7).
link(node9, node15, 150, 500).
link(node11, node12, 150, 500).
link(node11, node14, 100, 500).
