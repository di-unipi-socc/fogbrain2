placement(AppId, Placement) :-
	application(AppId, Services),
	placement(Services, ([],[]), Alloc, [], Placement),
	deploy(AppId, Placement, Alloc).

placement([], (AllocHW, AllocBW), (AllocHW, AllocBW), Placement, Placement).
placement([S|Ss], (AllocHW, AllocBW), NewAlloc, Placement, NewPlacement) :-
	servicePlacement(S, AllocHW, TAllocHW, N),
	flowOK(S, N, Placement, AllocBW, TAllocBW), 
	placement(Ss, (TAllocHW, TAllocBW), NewAlloc, [on(S,N)|Placement], NewPlacement).

servicePlacement(S, AllocHW, NewAllocHW, N) :-
	service(S, SWReqs, HWReqs, TReqs),
	node(N, SWCaps, HWCaps, TCaps),
	hwTh(T), HWCaps >= HWReqs + T,
	thingReqsOK(TReqs, TCaps),
	swReqsOK(SWReqs, SWCaps),
	hwReqsOK(HWReqs, HWCaps, N, AllocHW, NewAllocHW).

thingReqsOK(TReqs, TCaps) :- subset(TReqs, TCaps).

swReqsOK(SWReqs, SWCaps) :- subset(SWReqs, SWCaps).

hwReqsOK(HWReqs, HWCaps, N, [], [(N,HWReqs)]) :-
	hwTh(T), HWCaps >= HWReqs + T.
hwReqsOK(HWReqs, HWCaps, N, [(N,AllocHW)|L], [(N,NewAllocHW)|L]) :-
	NewAllocHW is AllocHW + HWReqs, hwTh(T), HWCaps >= NewAllocHW + T.
hwReqsOK(HWReqs, HWCaps, N, [(N1,AllocHW)|L], [(N1,AllocHW)|NewL]) :-
	dif(N,N1), hwReqsOK(HWReqs, HWCaps, N, L, NewL).

flowOK(S, N, Placement, AllocBW, NewAllocBW) :-
	findall(n2n(N1,N2,ReqLat,ReqBW), interested(N1,N2,ReqLat,ReqBW,S,N,Placement), N2Ns),
	serviceFlowOK(N2Ns, AllocBW, NewAllocBW).

interested(N, N2, ReqLat, ReqBW, S, N, Placement) :-
	s2s(S, S2, ReqLat, ReqBW), member(on(S2,N2), Placement), dif(N,N2).
interested(N1, N, ReqLat, ReqBW, S, N, Placement) :-
	s2s(S1, S, ReqLat, ReqBW), member(on(S1,N1), Placement), dif(N,N1).

serviceFlowOK([], AllocBW, AllocBW).
serviceFlowOK([n2n(N1,N2,ReqLat,ReqBW)|Ss], AllocBW, NewAllocBW) :-
	link(N1, N2, FeatLat, FeatBW),
	FeatLat =< ReqLat,
	bwOK(N1, N2, ReqBW, FeatBW, AllocBW, TAllocBW),
	serviceFlowOK(Ss, TAllocBW, NewAllocBW).

bwOK(N1, N2, ReqBW, FeatBW, [], [(N1,N2,ReqBW)]):-
	bwTh(T), FeatBW >= ReqBW + T.
bwOK(N1, N2, ReqBW, FeatBW, [(N1,N2,AllocBW)|L], [(N1,N2,NewAllocBW)|L]):-
	NewAllocBW is ReqBW + AllocBW, bwTh(T), FeatBW >= NewAllocBW + T.
bwOK(N1, N2, ReqBW, FeatBW, [(N3,N4,AllocBW)|L], [(N3,N4,AllocBW)|NewL]):-
	\+ (N1 == N3, N2 == N4), bwOK(N1,N2,ReqBW,FeatBW,L,NewL).

deploy(AppId, Placement, Alloc) :-
	findall(service(S, SW, HW, TH), service(S, SW, HW, TH), CtxServices),
	findall(s2s(S1, S2, LA, BW), s2s(S1, S2, LA, BW), CtxS2S),
	assert(deployment(AppId, Placement, Alloc, (CtxServices, CtxS2S))).