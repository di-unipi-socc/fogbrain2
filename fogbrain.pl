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

fogBrain(App, NewPlacement) :-
	deployment(App, Placement, AllocHW, AllocBW, Context),
	writeln('A deployment exist, starting a reasoning step...'),
	reasoningStep(App, Placement, AllocHW, AllocBW, Context, NewPlacement).
fogBrain(App, Placement) :-
	\+deployment(App,_,_,_,_),
	writeln('A deployment does not exist, starting placing the app...'),
	placement(App, Placement).

printDeployment(App) :-
	deployment(App, Placement, AllocHW, AllocBW, (Services, S2Ss)),
	writeln(deployment(App, Placement, AllocHW, AllocBW, (Services, S2Ss))).
