:-dynamic deployment/4.
:-dynamic application/2.
:-dynamic service/4.
:-dynamic s2s/4.
:-dynamic link/4.
:-dynamic node/4.

:-qcompile('utils.pl').
:-qcompile('./src/placer.pl').
:-qcompile('./src/reasoningB.pl').
:-use_module(library(lists)).

%%%% Thresholds to identify overloaded nodes and saturated e2e links%%%%
hwTh(0.5).
bwTh(0.2). 
itTh(10).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fogBrain(AppSpec, NewPlacement) :-
	loadSpec('infra.pl'), 
	loadSpec(AppSpec), %checkAppSpec(),
	application(AppId,_),
	deployment(AppId, Placement, Alloc, Context), %writeln('A deployment exist, starting a reasoning step...'),
	time(reasoningStep(AppId, Placement, Alloc, Context, NewPlacement)),
	unloadSpec('infra.pl'), unloadSpec(AppSpec).
fogBrain(AppSpec, Placement) :-
	application(AppId,_),
	\+deployment(AppId,_,_,_), %writeln('A deployment does not exist, starting placing the app...'),
	time(placement(AppId, Placement)),
	unloadSpec('infra.pl'), unloadSpec(AppSpec).
fogBrain(AppSpec,_) :-
	unloadSpec('infra.pl'), unloadSpec(AppSpec).
