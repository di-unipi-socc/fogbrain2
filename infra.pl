node(node0, [ubuntu, gcc, make], 4, [lamp, ac]).
node(node1, [], 20, [lamp, ac]).
node(node2, [android, gcc, make], 4, [lamp, ac]).
node(node3, [ubuntu, mySQL], 50, [lamp, ac]).
node(node4, [ubuntu], 4, [lamp, ac]).
node(node5, [], 2, [lamp, ac]).
node(node6, [ubuntu, mySQL], 50, [lamp, ac]).
node(node7, [ubuntu], inf, [lamp, ac]).
node(node8, [android], 8, [lamp, ac]).
node(node9, [ubuntu, mySQL], 20, [vrViewer]).
node(node10, [ubuntu, mySQL], 20, [lamp, ac]).
node(node11, [ubuntu, mySQL], 20, [lamp, ac]).
node(node12, [ubuntu, mySQL, gcc, make], inf, [vrViewer]).
node(node13, [ubuntu, mySQL], 20, [vrViewer]).
node(node14, [ubuntu, mySQL], 20, [lamp, ac]).
node(node15, [ubuntu, mySQL, gcc, make], inf, [lamp, ac]).
link(node0, node4, 5, 50).
link(node0, node5, 25, 2).
link(node0, node8, 200, 500).
link(node0, node9, 150, 2).
link(node0, node12, 50, 500).
link(node0, node13, 100, 500).
link(node1, node4, 200, 100).
link(node1, node5, 50, 500).
link(node1, node6, 5, 7).
link(node1, node7, 10, 500).
link(node1, node9, 25, 50).
link(node1, node10, 25, 20).
link(node1, node12, 25, 500).
link(node1, node13, 10, 100).
link(node1, node14, 50, 500).
link(node2, node4, 5, 7).
link(node3, node4, 10, 2).
link(node3, node5, 150, 100).
link(node3, node6, 10, 2).
link(node3, node7, 10, 50).
link(node3, node12, 150, 100).
link(node3, node14, 5, 500).
link(node4, node5, 200, 7).
link(node4, node6, 5, 20).
link(node4, node7, 5, 50).
link(node4, node8, 150, 50).
link(node4, node10, 50, 500).
link(node4, node11, 50, 2).
link(node4, node13, 50, 20).
link(node4, node15, 5, 20).
link(node5, node6, 150, 2).
link(node5, node7, 50, 500).
link(node5, node8, 10, 20).
link(node5, node11, 200, 500).
link(node5, node12, 100, 500).
link(node5, node15, 50, 7).
link(node6, node8, 5, 100).
link(node6, node9, 5, 20).
link(node6, node10, 25, 7).
link(node6, node11, 10, 50).
link(node6, node14, 200, 50).
link(node7, node9, 50, 2).
link(node7, node10, 200, 50).
link(node7, node13, 150, 100).
link(node7, node14, 25, 500).
link(node8, node11, 50, 500).
link(node8, node15, 100, 50).
link(node9, node15, 150, 100).
