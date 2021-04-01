:-dynamic deployment/4.
:-dynamic application/2.
:-dynamic service/4.
:-dynamic s2s/4.
:-dynamic link/4.
:-dynamic node/4.

:-consult('utils.pl').
:-consult('./src/placer.pl').
:-consult('./src/reasoningOld.pl').
:-use_module(library(lists)).

%%%% Thresholds to identify overloaded nodes and saturated e2e links%%%%
hwTh(0.5).
bwTh(0.2).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fogBrain(AppSpec, NewPlacement) :-
	consult('vrInfra.pl'), consult(AppSpec),
	application(AppId,_), deployment(AppId, Placement, Alloc, Context),
	time(reasoningStep(AppId, Placement, Alloc, Context, NewPlacement)),
	unload_file(AppSpec).
fogBrain(AppSpec, Placement) :-
	application(AppId,_), \+deployment(AppId,_,_,_),
	time(placement(AppId, Placement)),
	unload_file(AppSpec).
fogBrain(AppSpec,_) :-
	unload_file(AppSpec), fail.
