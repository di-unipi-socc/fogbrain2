cleanResourceAllocation(PartialPlacement, (A,B)) :-
	allocatedHWPP(PartialPlacement, [], A),
	allocatedBW(PartialPlacement, B).

allocatedHWPP([],X,X).
allocatedHWPP([on(S,N)|L],X,A) :-	
	service(S, _, HWReqs, _),
	countHWReqs(HWReqs, N, X, Y),
	allocatedHWPP(L,Y,A).	

countHWReqs(HWReqs, N, [], [(N,HWReqs)]).
countHWReqs(HWReqs, N, [(N,AllocHW)|L], [(N,NewAllocHW)|L]) :- NewAllocHW is AllocHW + HWReqs.
countHWReqs(HWReqs, N, [(N1,AllocHW)|L], [(N1,AllocHW)|NewL]) :- dif(N,N1), countHWReqs(HWReqs, N, L, NewL).

allocatedBW(PP, B) :-
	findall(n2n(N1, N2, ReqBW), (member(on(S1,N1), PP), member(on(S2,N2), PP), dif(N1,N2), s2s(S1, S2, _, ReqBW)), N2Ns),
	allocatedBW(N2Ns,[],B).

allocatedBW([],X,X).
allocatedBW([n2n(N1, N2, ReqBW)|L],X,A) :- countBW(N1, N2, ReqBW, X, Y), allocatedBW(L,Y,A).

countBW(N1, N2, ReqBW, [], [(N1,N2,ReqBW)]).
countBW(N1, N2, ReqBW, [(N1,N2,AllocBW)|L], [(N1,N2,NewAllocBW)|L]):- NewAllocBW is ReqBW + AllocBW.
countBW(N1, N2, ReqBW, [(N3,N4,AllocBW)|L], [(N3,N4,AllocBW)|NewL]):- (dif(N1,N3);dif(N2,N4)), countBW(N1,N2,ReqBW,L,NewL).