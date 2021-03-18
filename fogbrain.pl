:-qcompile('infra.pl').
:-qcompile('app.pl').
:-qcompile('utils.pl')
:-qcompile('./src/placer.pl').
:-qcompile('./src/reasoning.pl').
:-use_module(library(lists)).
:-dynamic deployment/5.

%%%% Thresholds to identify overloaded nodes and saturated e2e links%%%%
hwTh(0.5).
bwTh(0.2). 
itTh(10).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fogBrain(AppSpec, NewPlacement) :-
	consult('infra.pl'), 
	consult(AppSpec), checkAppSpec(),
	application(AppId,_),
	deployment(AppId, Placement, AllocHW, AllocBW, Context), %writeln('A deployment exist, starting a reasoning step...'),
	time(reasoningStep(AppId, Placement, AllocHW, AllocBW, Context, NewPlacement)).
fogBrain(_, Placement) :-
	application(AppId,_),
	\+deployment(AppId,_,_,_,_), %writeln('A deployment does not exist, starting placing the app...'),
	time(placement(AppId, Placement)).

