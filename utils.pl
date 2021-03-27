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


stat(Goal, Inferences) :-
    statistics(inferences, OldInferences),
    call(Goal),
    statistics(inferences, NewInferences),
    Inferences is NewInferences - OldInferences.
    
fogBrain(AppId, NewPlacement, Inferences) :-
	deployment(AppId, Placement, Alloc, Context),
	stat(reasoningStep(AppId, Placement, Alloc, Context, NewPlacement), Inferences).
fogBrain(AppId, Placement, Inferences) :-
	\+deployment(AppId,_,_,_),
	stat(placement(AppId, Placement), Inferences).

assessFogBrain(AppSpec, (Inferences1, Placement1, Alloc1), (Inferences2, Placement2, Alloc2)) :-
	consult('infra.pl'), consult(AppSpec),
	application(AppId,_), 
	fogBrain(AppId, Placement1, Inferences1),
	deployment(AppId, Placement1, Alloc1, Ctx),
	retract(deployment(AppId, _, _, _)),
	fogBrain(AppId, Placement2, Inferences2),
	deployment(AppId, Placement2, Alloc2, _),
	retract(deployment(AppId, _, _, _)),
	assert(deployment(AppId, Placement1, Alloc1, Ctx)),
	unload_file(AppSpec).
