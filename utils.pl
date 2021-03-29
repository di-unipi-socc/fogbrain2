checkAppSpec() :-
	findall(1, application(AppId,_),[1]),
	application(AppId, Services),
	findall(S, service(S,_,_,_), ServiceDecl),
	msort(Services, SServices), msort(ServiceDecl, SServiceDecl),
	SServices=SServiceDecl.

del:- retract(deployment(vrApp,_,_,_)).

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

fb(NewPlacement) :-
	application(AppId,_), deployment(AppId, Placement, Alloc, Context),
	reasoningStep(AppId, Placement, Alloc, Context, NewPlacement).
fb(Placement) :-
	application(AppId,_), \+deployment(AppId,_,_,_),
	placement(AppId, Placement).

fogBrain(AppSpec, Infra, NewPlacement, NewPlacement1, InferencesCR, InferencesNoCR) :-
	consult(Infra),consult(AppSpec),
	stat(fb(NewPlacement), InferencesCR),
	findall(deployment(A, P, All, C), deployment(A, P, All, C),[D]),
	retract(D), stat(fb(NewPlacement1),InferencesNoCR), retract(deployment(_,_,_,_)), assert(D),
	unload_file(AppSpec).

stat(Goal, Inferences) :-
    statistics(inferences, OldInferences),
    call(Goal),
    statistics(inferences, NewInferences),
    Inferences is NewInferences - OldInferences.
