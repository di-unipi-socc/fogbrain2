:-qcompile('infra.pl').
:-qcompile('app.pl').
:-qcompile('./src/placer.pl').
:-qcompile('./src/reasoning.pl').
:-use_module(library(lists)).
:-dynamic deployment/5.

%%%% Thresholds to identify overloaded nodes and saturated e2e links%%%%
hwTh(0.5).
bwTh(0.2). 
itTh(10).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

del :- retract(deployment(vrApp, _, _, _, _)).
test(P) :- make,fogBrain(vrApp,P).

checkAppSpec() :-
	findall(1, application(AppId,_),[1]),
	application(AppId, Services),
	findall(S, service(S,_,_,_), ServiceDecl),
	msort(Services, SServices), msort(ServiceDecl, SServiceDecl),
	SServices=SServiceDecl.

fogBrain(AppSpec, NewPlacement) :-
	consult('infra.pl'), 
	consult(AppSpec), checkAppSpec(),
	application(AppId,_),
	deployment(AppId, Placement, AllocHW, AllocBW, Context), %writeln('A deployment exist, starting a reasoning step...'),
	time(reasoningStep(AppId, Placement, AllocHW, AllocBW, Context, NewPlacement)).
fogBrain(_, Placement) :-
	application(AppId,_),
	\+deployment(AppId,_,_,_,_),%writeln('A deployment does not exist, starting placing the app...'),
	time(placement(AppId, Placement)).

%%% EXPLAINABILITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rimane da capire perché una data configurazione non va bene
deployment(App) :-
	deployment(App, Placement, AllocHW, AllocBW, (Services, S2Ss)),
	write('App: '), writeln(App),
	write('Placement: '), writeln(Placement),
	write('AllocHW: '), writeln(AllocHW),
	write('AllocBW: '), writeln(AllocBW),
	write('Context: '), writeln((Services, S2Ss)).
