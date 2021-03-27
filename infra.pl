node(node0, [ubuntu, gcc, make], 4, []).
node(node1, [ubuntu], 50, []).
node(node2, [ubuntu], 4, []).
node(node3, [ubuntu, gcc, make], 4, []).
node(node4, [ubuntu, gcc, make], 4, []).
node(node5, [ubuntu, mySQL, gcc, make], inf, []).
node(node6, [ubuntu], 0, []).
node(node7, [ubuntu, mySQL], 20, []).
node(node8, [ubuntu, mySQL], 50, []).
node(node9, [ubuntu, mySQL], 25, []).
node(node10, [andorid], 8, []).
node(node11, [android, gcc, make], 4, []).
node(node12, [ubuntu, mySQL], 50, []).
node(node13, [ubuntu, mySQL], 50, []).
node(node14, [ubuntu, mySQL], 0, []).
node(node15, [ubuntu], 20, []).
link(node0, node4, 5, 2).
link(node0, node5, 100, 100).
link(node0, node6, 10, 2).
link(node0, node14, 200, 50).
link(node1, node4, 50, 100).
link(node1, node5, 25, 7).
link(node1, node6, 25, 100).
link(node1, node7, 5, 50).
link(node1, node9, 5, 2).
link(node1, node10, 10, 20).
link(node1, node12, 50, 7).
link(node2, node4, 200, 2).
link(node2, node5, 50, 20).
link(node2, node12, 150, 100).
link(node2, node14, 10, 20).
link(node3, node4, 10, 7).
link(node4, node5, 100, 50).
link(node4, node6, 150, 20).
link(node4, node7, 200, 20).
link(node4, node8, 25, 7).
link(node4, node11, 10, 2).
link(node5, node6, 50, 20).
link(node5, node7, 25, 100).
link(node5, node8, 100, 500).
link(node5, node9, 5, 100).
link(node5, node10, 5, 7).
link(node5, node13, 150, 500).
link(node5, node15, 25, 500).
link(node6, node7, 5, 20).
link(node6, node8, 10, 20).
link(node6, node9, 25, 7).
link(node6, node11, 50, 100).
link(node6, node12, 150, 7).
link(node6, node13, 200, 7).
link(node7, node8, 150, 100).
link(node7, node10, 200, 50).
link(node7, node11, 200, 2).
link(node7, node15, 100, 500).
link(node8, node9, 100, 7).
link(node9, node10, 5, 100).
link(node9, node11, 100, 20).
link(node9, node12, 200, 7).
link(node9, node13, 100, 50).
link(node9, node14, 200, 500).
link(node11, node13, 5, 500).
link(node12, node14, 25, 20).
link(node12, node15, 150, 50).
link(node13, node15, 5, 2).
