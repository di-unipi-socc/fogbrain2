checkAppSpec() :-
	findall(1, application(AppId,_),[1]),
	application(AppId, Services),
	findall(S, service(S,_,_,_), ServiceDecl),
	msort(Services, SServices), msort(ServiceDecl, SServiceDecl),
	SServices=SServiceDecl.

deployment(App) :-
	deployment(App, Placement, (AllocHW, AllocBW), (Services, S2Ss)),
	write('App: '), writeln(App),
	write('Placement: '), writeln(Placement),
	write('AllocHW: '), writeln(AllocHW),
	write('AllocBW: '), writeln(AllocBW),
	write('Context: '), writeln((Services, S2Ss)).

listDiff(_,[],[]).
listDiff(L1,[L|Ls],Add) :- member(L,L1), listDiff(L1,Ls,Add).
listDiff(L1,[L|Ls],[L|Add]) :- \+ member(L,L1), listDiff(L1,Ls,Add).
