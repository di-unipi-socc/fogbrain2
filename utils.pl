:-dynamic deployment/4.


del:- retract(deployment(vrApp,_,_,_)).

deployment() :-
	deployment(App, Placement, (AllocHW, AllocBW), (Services, S2Ss)),
	write('App: '), writeln(App),
	write('Placement: '), writeln(Placement),
	write('AllocHW: '), writeln(AllocHW),
	write('AllocBW: '), writeln(AllocBW),
	write('Context: '), writeln((Services, S2Ss)).

cr(AppSpec, NewPlacement, InferencesCR, TimeCR):-
	consult(AppSpec), consult('deployment.pl'), set_random(seed(481183)),
	statistics(inferences, Before1),
		statistics(cputime, T1),
			fb(NewPlacement),
		statistics(cputime, T2),
	statistics(inferences, After1), InferencesCR is After1 - Before1 - 5, TimeCR is T2 - T1,
	findall(deployment(A, P, All, C), deployment(A, P, All, C),[D]), writeDeployment(D), 
	D=deployment(_, _, (_, AllocBW), _), random(F), %writeln(F),
	(
		( F =< 0.15, changeNode(NewPlacement) );
		( F > 0.15, F =< 0.30, changeLink(AllocBW));
		( F > 0.30 )
	),
	retractall(D), unload_file(AppSpec).

p(AppSpec, NewPlacement, InferencesNoCR, TimeNoCR) :-
	consult(AppSpec), application(AppId,_),
	statistics(inferences, Before2),
		statistics(cputime, T1),
			placement(AppId, NewPlacement), 
		statistics(cputime, T2),
	statistics(inferences, After2), InferencesNoCR is After2 - Before2 - 5, TimeNoCR is T2 - T1, retractall(deployment(_,_,_,_)),
	unload_file(AppSpec).

changeNode(P) :- 
	random_member(on(_,TargetNode), P), 
	retract(node(TargetNode,SW,HW,T)), 
	( (dif(HW, inf), HWMax is 1.3*HW); HWMax = 100 ),
	random_range(0.1, HWMax, 10, L), random_member(NewHW, L),
	assert(node(TargetNode,SW,NewHW,T)).

changeLink(AllocBW) :- 
	random_member((N1,N2,_), AllocBW), 
	retract(link(N1,N2,Lat,BW)), 
	( (dif(BW, inf), BWMax is 1.3*BW ); BWMax = 100 ),
	random_range(0.1, BWMax, 10, L1), random_member(NewBW, L1),
	MaxLat is Lat + 1,
	random_range(1, MaxLat, 10, L2), random_member(NewLat, L2),
	assert(link(N1,N2,NewLat,NewBW)).

random_range(_,_,0,[]).
random_range(L, U, N, [R|Ls]) :-
    random(L,U,R),
    NewN is N-1,
    random_range(L,U,NewN,Ls).

fb(NewPlacement) :-
	application(AppId,_), deployment(AppId, Placement, _, Context),
	reasoningStep(AppId, Placement, Context, NewPlacement).
fb(Placement) :-
	application(AppId,_), \+deployment(AppId,_,_,_),
	placement(AppId, Placement).

writeDeployment(D) :-
    open('deployment.pl',write,Out),
    write(Out,D), write(Out,'.\n'),
    close(Out).

loadInfra :- unload_file('infra.pl'),consult('infra.pl').