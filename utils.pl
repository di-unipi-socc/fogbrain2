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
	consult(Infra), consult(AppSpec),
	stat(fb(NewPlacement), InferencesCR),
	findall(deployment(A, P, All, C), deployment(A, P, All, C),[D]),
	retract(D), stat(fb(NewPlacement1),InferencesNoCR), retract(deployment(_,_,_,_)), assert(D),
	unload_file(AppSpec).

stat(Goal, Inferences) :-
    statistics(inferences, OldInferences),
    call(Goal),
    statistics(inferences, NewInferences),
    Inferences is NewInferences - OldInferences.
<<<<<<< HEAD
=======
    
testFogBrain(AppId, NewPlacement) :-
	deployment(AppId, Placement, Alloc, Context),
	reasoningStep(AppId, Placement, Alloc, Context, NewPlacement).
testFogBrain(AppId, Placement) :-
	\+deployment(AppId,_,_,_),
	placement(AppId, Placement).

assessFogBrain(AppSpec, (Inferences1, Placement1, Alloc1), (Inferences2, Placement2, Alloc2)) :-
	consult('deployment.pl'),
	consult(AppSpec),
	application(AppId,_), 
	stat(testFogBrain(AppId, Placement1), Inferences1),
	deployment(AppId, Placement1, Alloc1, Ctx),
	retract(deployment(AppId, _, _, _)),
	stat(testFogBrain(AppId, Placement2), Inferences2),
	deployment(AppId, Placement2, Alloc2, _),
	retract(deployment(AppId, _, _, _)),
	%assert(deployment(AppId, Placement1, Alloc1, Ctx)),
	open('deployment.pl',write,Out),
    write(Out,deployment(AppId, Placement1, Alloc1, Ctx)),
	write(Out, '.'),
	close(Out),
	unload_file(AppSpec), unload_file('infra.pl').
>>>>>>> 843878d11d3b64e9843126a911f7072f45b42cd3
