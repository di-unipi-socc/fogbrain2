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

%%% EXPLAINABILITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rimane da capire perché una data configurazione non va bene
deployment(App) :-
	deployment(App, Placement, AllocHW, AllocBW, (Services, S2Ss)),
	writeln(deployment(App, Placement, AllocHW, AllocBW, (Services, S2Ss))).

why(App, Failing) :-
	why(App, _, Failing).

why(App, Kernel, Failing) :-
	application(App, Services),
	why(App, Services, Kernel, Failing).

why(_, [], [], []).
why(App, Services, FinalKernel, FinalFailing) :-
	failingConf(App, Services, TmpKernel),
	plain(TmpKernel,Kernel),
	failingConf(App, Kernel, _, _, Failing),
	findall(S, (member(S, Services), \+member(S, Kernel)), NewServices),
	(why(App, NewServices, NewKernel, NewFailing) ->
		(append(Kernel, NewKernel, FinalKernel),
		append(Failing, NewFailing, FinalFailing))
		;
		(FinalKernel=Kernel,FinalFailing=Failing)).

placebable(App, Services, NewPlacement) :-
	deployment(App, Placement, AllocHW, AllocBW, Context),
	Context=(ContextServices,_),
	findall(S, member(on(S,_),Placement), Placed),
	append(Placed,Services,Tmp), sort(Tmp, ToPlace),
	findall((S,N,HWReqs), (member(S,ToPlace), member(on(S,N),Placement), member(service(S,_,HWReqs,_), ContextServices)), ToRemove),
	removeServices(ToRemove, Placement, PPlacement, AllocHW, PAllocHW, AllocBW, PAllocBW),
	placement(ToPlace, PAllocHW, _, PAllocBW, _, PPlacement, NewPlacement).

failingConf(App, Services, Intersect, SmallestList, List) :-
	findall(Conf, (genSubset(Services, Conf), \+placebable(App, Conf, _)), List),
	intersect(List, Intersect),
	smallestList(List, Smallest),
	length(Smallest, SLen),
	genAllSmallest(List,SLen,SmallestList).

failingConf(App, Services, Kernel) :-
	failingConf(App, Services, Intersect, [Smallest|SmallestList], _),
	length(Intersect, ILen), length(Smallest, SLen),
	(SLen >= ILen -> Kernel = [Smallest|SmallestList]; Kernel = Intersect).

failingConf(App, Intersect, SmallestList, List) :-
	application(App, Services),
	failingConf(App, Services, Intersect, SmallestList, List).

failingConf(App, Kernel) :-
	application(App, Services),
	failingConf(App, Services, Kernel).
	
genAllSmallest(List,SmallestLen,Kernel) :-
	findall(Ls, (member(Ls,List), length(Ls,Len), Len == SmallestLen), Kernel).

smallestList([L|Ls], Min) :- 
	foldl(smallestList, Ls, L, Min).

smallestList(X, Y, Min) :- 
	length(X, XLen), length(Y, YLen),
	(XLen < YLen -> Min = X; Min = Y).

intersect([], []).
intersect([L|List], Int) :-
	intersect(List, L, Int).

intersect([], Int, Int).
intersect([L|List], Acc, Int) :-
    intersection(L, Acc, NewAcc),
	intersect(List, NewAcc, Int).

plain([], []).
plain([L|List], [L|List]) :-
	\+is_list(L).
plain([L|List], U) :-
	is_list(L),
	plain(List, L, U).

plain([], U, U).
plain([L|List], Acc, U) :-
    unionOfList(L, Acc, NewAcc),
	plain(List, NewAcc, U).

unionOfList([],[],[]).
unionOfList(List1,[],List1).
unionOfList(List1, [Head2|Tail2], [Head2|Output]):-
    \+(member(Head2,List1)), unionOfList(List1,Tail2,Output).
unionOfList(List1, [Head2|Tail2], Output):-
    member(Head2,List1), unionOfList(List1,Tail2,Output).

genSubset([], []).
genSubset([E|Tail], [E|NTail]):-
	genSubset(Tail, NTail).
genSubset([_|Tail], NTail):-
	genSubset(Tail, NTail).