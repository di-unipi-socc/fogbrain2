reasoningStep(App, Placement, AllocHW, AllocBW, Context, NewPlacement) :-
    toUpdate(App, Placement, Context, ToRemove, ToAdd, ToUpdate, ToMigrate),
    cleanDeployment(Placement, AllocHW, AllocBW, ToRemove, ToUpdate, ToMigrate, PPlacement, PAllocHW, PAllocBW, Context),
    servicesToPlace(ToMigrate, ToAdd, ToPlace),
    replacement(App, ToPlace, PPlacement, PAllocHW, PAllocBW, NewPlacement).

toUpdate(App, Placement, Context, ToRemove, ToAdd, ToUpdate, ToMigrate) :-
    toUpdateDueToRequirementsChanges(App, Placement, Context, ToRemove, ToAdd, ToUpdate, ToMigrate1),
    toUpdateDueToInfrastructureChanges(Placement, ToMigrate2), 
    union(ToMigrate1, ToMigrate2, ToMigrate).

cleanDeployment(Placement, AllocHW, AllocBW, ToRemove, _, ToMigrate, PPlacement, PAllocHW, PAllocBW, Context) :-
    union(ToRemove,ToMigrate,ToClean),
    removeServices(ToClean, Placement, PPlacement, AllocHW, PAllocHW, AllocBW, PAllocBW, Context).

servicesToPlace(ToMigrate, ToAdd, ToPlace) :-
    findall(S, member((S,_,_),ToMigrate), ToPlace1),
    findall(S, member((S,_,_),ToAdd), ToPlace2),
    union(ToPlace1, ToPlace2, ToPlace).

removeServices(ToRemove, Placement, PPlacement, AllocHW, PAllocHW, AllocBW, PAllocBW, Context) :-
    freeHWAllocation(AllocHW, PAllocHW, ToRemove),
    Context=(_,ContextS2S), freeBWAllocation(AllocBW, PAllocBW, ToRemove, Placement, ContextS2S),
    partialPlacement(Placement, ToRemove, PPlacement).

toUpdateDueToRequirementsChanges(App, Placement, Context, ToRemove, ToAdd, ToUpdate, ToMigrate) :-
    Context=(ContextServices,ContextS2S),
    findall((S,N,HWReqs), removedService(App, S, N, HWReqs, Placement, ContextServices), ToRemove),
    findall((S,_,HWReqs), addedService(App, S, HWReqs, Placement), ToAdd),
    findall((S,N,HWReqs), changedServiceToMigrate(S, N, HWReqs, Placement, ContextServices), ToMigrate1),
    findall((S,N,HWReqs), changedServiceToUpdate(S, N, HWReqs, Placement, ContextServices), ToUpdate1),
    findall((SD1,SD2), changedS2SToMigrate(SD1, SD2, Placement, ContextS2S, ContextServices), ToMigrate2),
    findall((SD1,SD2), changedS2SToUpdate(SD1, SD2, Placement, ContextS2S, ContextServices), ToUpdate2),
    merge(ToMigrate2, ToMigrate1, ToMigrate), merge(ToUpdate2, ToUpdate1, ToUpdate).

changedServiceToMigrate(S, N, HWReqs, Placement, ContextServices) :-
    member(on(S,N), Placement),
    serviceDiff(S, HWReqs, SWDiff, HWDiff, TDiff, ContextServices),
    node(N, SWCaps, HWCaps, TCaps),
    hwTh(T), \+ (swReqsOK(SWDiff, SWCaps), HWCaps > HWDiff + T, thingReqsOK(TDiff, TCaps)).

changedServiceToUpdate(S, N, HWReqs, Placement, ContextServices) :-
    member(on(S,N), Placement),
    serviceDiff(S, HWReqs, SWDiff, HWDiff, TDiff, ContextServices),
    (dif(SWDiff,[]); dif(HWDiff,0); dif(TDiff,[])),
    node(N, SWCaps, HWCaps, TCaps),
    swReqsOK(SWDiff, SWCaps), hwTh(T), HWCaps > HWDiff + T, thingReqsOK(TDiff, TCaps).

serviceDiff(S, HWReqsOld, SWDiff, HWDiff, TDiff, ContextServices) :-
    member(service(S, SWReqsOld, HWReqsOld, TReqsOld),ContextServices),
    service(S, SWReqs, HWReqs, TReqs),
    HWDiff is HWReqs - HWReqsOld,
    listDiff(SWReqsOld, SWReqs, SWDiff),
    listDiff(TReqsOld, TReqs, TDiff).

changedS2SToMigrate((S1,N1,HWReqs1), (S2,N2,HWReqs2), Placement, ContextS2S, ContextServices) :-
    member(on(S1,N1),Placement), member(on(S2,N2),Placement),
    dif(N1,N2), 
    s2sDiff((S1,HWReqs1), (S2,HWReqs2), (_, ReqLat), BWDiff, ContextS2S, ContextServices),
    link(N1, N2, FeatLat, FeatBW),
    bwTh(T), \+ (ReqLat >= FeatLat, FeatBW > BWDiff + T).

changedS2SToUpdate((S1,N1,HWReqs1), (S2,N2,HWReqs2), Placement, ContextS2S, ContextServices) :-
    member(on(S1,N1),Placement), member(on(S2,N2),Placement), 
    dif(N1,N2),
    s2sDiff((S1,HWReqs1), (S2,HWReqs2), (LatDiff,ReqLat), BWDiff, ContextS2S, ContextServices),
    (dif(LatDiff,0); dif(BWDiff,0)),
    link(N1, N2, FeatLat, FeatBW),
    ReqLat >= FeatLat, bwTh(T), FeatBW > BWDiff + T.

s2sDiff((S1,HWReqs1Old), (S2,HWReqs2Old), (LatDiff,ReqLat), BWDiff, ContextS2S, ContextServices) :-
    member(s2s(S1, S2, ReqLatOld, ReqBWOld),ContextS2S),
    s2s(S1, S2, ReqLat, ReqBW),
    BWDiff is ReqBW - ReqBWOld,
    LatDiff is ReqLat -ReqLatOld,
    member(service(S1, _, HWReqs1Old, _),ContextServices),
    member(service(S2, _, HWReqs2Old, _),ContextServices).

removedService(App,S,N,HWReqs,Placement,ContextServices) :-
    member(on(S,N),Placement),
    application(App,Services), \+member(S,Services),
    member(service(S,_,HWReqs,_), ContextServices).

addedService(App,S,HWReqs,Placement) :-
    application(App,Services), member(S,Services),
    \+member(on(S,_),Placement),
    service(S,_,HWReqs,_).

toUpdateDueToInfrastructureChanges(Placement, ServicesToMigrate) :-
    findall((S,N,HWReqs), onSufferingNode(S,N,HWReqs,Placement), ServiceDescr1),
    findall((SD1,SD2), onSufferingLink(SD1,SD2,Placement), ServiceDescr2),
    merge(ServiceDescr2, ServiceDescr1, ServicesToMigrate).

onSufferingNode(S, N, HWReqs, Placement) :-  
    member(on(S,N), Placement),
    service(S, SWReqs, HWReqs, TReqs),
    nodeProblem(N, SWReqs, TReqs).

nodeProblem(N, SWReqs, TReqs) :-
    node(N, SWCaps, HWCaps, TCaps),
    hwTh(T), \+ (HWCaps > T, thingReqsOK(TReqs,TCaps), swReqsOK(SWReqs,SWCaps)).
nodeProblem(N, _, _) :- 
    \+ node(N, _, _, _).

onSufferingLink((S1,N1,HWReqs1),(S2,N2,HWReqs2),Placement) :-
    member(on(S1,N1), Placement), member(on(S2,N2), Placement), N1 \== N2,
    s2s(S1, S2, ReqLat, _),
    communicationProblem(N1, N2, ReqLat),
    service(S1, _, HWReqs1, _),
    service(S2, _, HWReqs2, _).

communicationProblem(N1, N2, ReqLat) :- 
    link(N1, N2, FeatLat, FeatBW), 
    (FeatLat > ReqLat; bwTh(T), FeatBW < T).
communicationProblem(N1,N2,_) :- 
    \+ link(N1, N2, _, _).

merge([], L, L).
merge([(D1,D2)|Ds], L, NewL) :- merge2(D1, L, L1), merge2(D2, L1, L2), merge(Ds, L2, NewL).
merge2(D, [], [D]).
merge2(D, [D|L], [D|L]).
merge2(D1, [D2|L], [D2|NewL]) :- D1 \== D2, merge2(D1, L, NewL).

replacement(A, [], Placement, AllocHW, AllocBW, Placement) :-
    application(A, Services),
    findall(service(S, SW, HW, TH), (member(S,Services), service(S, SW, HW, TH)), ContextServices),
	findall(s2s(S, S2, LA, BW), (member(S,Services), s2s(S, S2, LA, BW)), ContextS2S),
    writeln('ciao1'),
    retract(deployment(A, _, _, _, _)),
	assert(deployment(A, Placement, AllocHW, AllocBW, (ContextServices, ContextS2S))).

replacement(A, ServicesToPlace, Placement, AllocHW, AllocBW, NewPlacement) :-
    ServicesToPlace \== [],
    placement(ServicesToPlace, AllocHW, NewAllocHW, AllocBW, NewAllocBW, Placement, NewPlacement),
    
    application(A, Services),
    findall(service(S, SW, HW, TH), (member(S,Services), service(S, SW, HW, TH)), ContextServices),
	findall(s2s(S, S2, LA, BW), (member(S,Services), s2s(S, S2, LA, BW)), ContextS2S),
    writeln('ciao2'),
    retract(deployment(A, _, _, _, _)),
	assert(deployment(A, NewPlacement, NewAllocHW, NewAllocBW, (ContextServices, ContextS2S))).


partialPlacement([],_,[]).
partialPlacement([on(S,_)|P],Services,PPlacement) :-
    member((S,_,_),Services), partialPlacement(P,Services,PPlacement).
partialPlacement([on(S,N)|P],Services,[on(S,N)|PPlacement]) :-
    \+member((S,_,_),Services), partialPlacement(P,Services,PPlacement).
 
freeHWAllocation([], [], _).
freeHWAllocation([(N,AllocHW)|L], NewL, Services) :-
    sumNodeHWToFree(N, Services, HWToFree),
    NewAllocHW is AllocHW - HWToFree, 
    freeHWAllocation(L, TempL, Services),
    assemble((N,NewAllocHW), TempL, NewL).

sumNodeHWToFree(_, [], 0).
sumNodeHWToFree(N, [(_,N,H)|STMs], Tot) :- sumNodeHWToFree(N, STMs, HH), Tot is H+HH.
sumNodeHWToFree(N, [(_,N1,_)|STMs], H) :- N \== N1, sumNodeHWToFree(N, STMs, H).
 
assemble((_,NewAllocHW), L, L) :- NewAllocHW=:=0.
assemble((N, NewAllocHW), L, [(N,NewAllocHW)|L]) :- NewAllocHW>0.
 
freeBWAllocation([],[],_,_,_).
freeBWAllocation([(N1,N2,AllocBW)|L], NewL, Services, Placement, ContextS2S) :-
   findall(BW, toFree(N1,N2,BW,Services,Placement, ContextS2S), BWs),
   sumLinkBWToFree(BWs,V), NewAllocBW is AllocBW-V,
   freeBWAllocation(L, TempL, Services, Placement, ContextS2S),
   assemble2((N1,N2,NewAllocBW), TempL, NewL).

toFree(N1,N2,B,Services,_,ContextS2S) :- 
    member((S1,N1,_),Services), 
    member(s2s(S1, S2, _, B),ContextS2S), member((S2,N2,_),Services). 
toFree(N1,N2,B,Services,P, ContextS2S) :- 
    member((S1,N1,_),Services), member(s2s(S1, S2, _, B),ContextS2S),
    \+member((S2,N2,_),Services), member(on(S2,N2),P). 
toFree(N1,N2,B,Services,P, ContextS2S) :- 
    member(on(S1,N1),P), 
    \+member((S1,N1,_),Services), member(s2s(S1, S2, _, B),ContextS2S), member((S2,N2,_),Services).
 
sumLinkBWToFree([],0).
sumLinkBWToFree([B|Bs],V) :- sumLinkBWToFree(Bs,TempV), V is B+TempV.

assemble2((_,_,AllocatedBW), L, L) :- AllocatedBW =:= 0.
assemble2((N1,N2,AllocatedBW), L, [(N1,N2,AllocatedBW)|L]) :- AllocatedBW>0.

listDiff(_,[],[]).
listDiff(L1,[L|Ls],Add) :- member(L,L1), listDiff(L1,Ls,Add).
listDiff(L1,[L|Ls],[L|Add]) :- \+ member(L,L1), listDiff(L1,Ls,Add).