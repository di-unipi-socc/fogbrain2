:-dynamic deployment/4.
:-dynamic application/2.
:-dynamic service/4.
:-dynamic s2s/4.
:-dynamic link/4.
:-dynamic node/4.

del:- retract(deployment(vrApp,_,_,_)).

deployment() :-
	deployment(App, Placement, (AllocHW, AllocBW), (Services, S2Ss)),
	write('App: '), writeln(App),
	write('Placement: '), writeln(Placement),
	write('AllocHW: '), writeln(AllocHW),
	write('AllocBW: '), writeln(AllocBW),
	write('Context: '), writeln((Services, S2Ss)).

cr(AppSpec, Infra, NewPlacement, InferencesCR, TimeCR):-
	consult(AppSpec), consult(Infra), consult('deployment.pl'),
	statistics(inferences, Before1),
		statistics(cputime, T1),
			fb(NewPlacement),
		statistics(cputime, T2),
	statistics(inferences, After1), InferencesCR is After1 - Before1 - 5, TimeCR is T2 - T1,
	findall(deployment(A, P, All, C), deployment(A, P, All, C),[D]), writeDeployment(D), retractall(D).

p(AppSpec, Infra, NewPlacement, InferencesNoCR, TimeNoCR) :-
	consult(AppSpec), consult(Infra), application(AppId,_),
	statistics(inferences, Before2),
		statistics(cputime, T1),
			placement(AppId, NewPlacement), 
		statistics(cputime, T2),
	statistics(inferences, After2), InferencesNoCR is After2 - Before2 - 5, TimeNoCR is T2 - T1, retractall(deployment(_,_,_,_)).

fb(NewPlacement) :-
	application(AppId,_), deployment(AppId, Placement, Alloc, Context),
	reasoningStep(AppId, Placement, Alloc, Context, NewPlacement).
fb(Placement) :-
	application(AppId,_), \+deployment(AppId,_,_,_),
	placement(AppId, Placement).

writeDeployment(D) :-
    open('deployment.pl',write,Out),
    write(Out,D), write(Out,'.\n'),
    close(Out).