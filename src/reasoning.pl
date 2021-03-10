reasoningStep(App, Placement, AllocHW, AllocBW, Context, NewPlacement) :-
    toUpdate(App, Placement, Context, ToRemove, ToAdd, ToUpdate, ToMigrate),
    cleanDeployment(Placement, AllocHW, AllocBW, ToRemove, ToUpdate, ToMigrate, PPlacement, PAllocHW, PAllocBW),
    servicesToPlace(ToMigrate, ToAdd, ToPlace),
    replacement(App, ToPlace, PPlacement, PAllocHW, PAllocBW, NewPlacement).

toUpdate(App, Placement, Context, ToRemove, ToAdd, ToUpdate, ToMigrate) :-
    toUpdateDueToRequirementsChanges(App, Placement, Context, ToRemove, ToAdd, ToUpdate, ToMigrate1),
    toUpdateDueToInfrastructureChanges(Placement, ToMigrate2), 
    merge(ToMigrate1, ToMigrate2, ToMigrate).

cleanDeployment(Placement, AllocHW, AllocBW, ToRemove, _, ToMigrate, PPlacement, PAllocHW, PAllocBW) :-
    append(ToRemove,ToMigrate,ToClean),
    removeServices(ToClean, Placement, PPlacement, AllocHW, PAllocHW, AllocBW, PAllocBW).

servicesToPlace(ToMigrate, ToAdd, ToPlace) :-
    findall(S, member((S,_,_),ToMigrate), ToPlace1),
    findall(S, member((S,_,_),ToAdd), ToPlace2),
    merge(ToPlace1, ToPlace2, ToPlace).

removeServices(ToRemove, Placement, PPlacement, AllocHW, PAllocHW, AllocBW, PAllocBW) :-
    freeHWAllocation(AllocHW, PAllocHW, ToRemove),
    freeBWAllocation(AllocBW, PAllocBW, ToRemove, Placement),
    partialPlacement(Placement, ToRemove, PPlacement).

toUpdateDueToRequirementsChanges(App, Placement, Context, ToRemove, ToAdd, ToUpdate, ToMigrate) :-
    Context=(ContextServices,_),
    findall((S,N,HWReqs), removedService(App, S, N, HWReqs, Placement, ContextServices), ToRemove),
    findall((S,_,HWReqs), addedService(App, S, HWReqs, Placement), ToAdd),
    ToUpdate = [],
    ToMigrate = [].
    %changedRequirements.

removedService(App,S,N,HWReqs,Placement,ContextServices) :-
    member(on(S,N),Placement),
    application(App,Services), \+member(S,Services),
    member(service(S,_,HWReqs,_), ContextServices).

addedService(App,S,HWReqs,Placement) :-
    application(App,Services), member(S,Services),
    \+member(on(S,_),Placement),
    service(S,_,HWReqs,_).

% changedRequirements :-
%    changedServicesRequirements
%    changedS2SRequirements.

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

onSufferingLink((S1,N1,-HWReqs1,migrate),(S2,N2,-HWReqs2,migrate),Placement) :-
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
	findall(s2s(S, S2, LA, BW), (member(S,Services), s2s(S, S2, LA, BW)), ContextS2Ss),
    writeln('ciao1'),
    retract(deployment(A, _, _, _, _)),
	assert(deployment(A, Placement, AllocHW, AllocBW, (ContextServices, ContextS2Ss))).

replacement(A, ServicesToPlace, Placement, AllocHW, AllocBW, NewPlacement) :-
    ServicesToPlace \== [],
    placement(ServicesToPlace, AllocHW, NewAllocHW, AllocBW, NewAllocBW, Placement, NewPlacement),
    
    application(A, Services),
    findall(service(S, SW, HW, TH), (member(S,Services), service(S, SW, HW, TH)), ContextServices),
	findall(s2s(S, S2, LA, BW), (member(S,Services), s2s(S, S2, LA, BW)), ContextS2Ss),
    writeln('ciao2'),
    retract(deployment(A, _, _, _, _)),
	assert(deployment(A, NewPlacement, NewAllocHW, NewAllocBW, (ContextServices, ContextS2Ss))).


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
 
freeBWAllocation([],[],_,_).
freeBWAllocation([(N1,N2,AllocBW)|L], NewL, Services, Placement) :-
   findall(BW, toFree(N1,N2,BW,Services,Placement), BWs),
   sumLinkBWToFree(BWs,V), NewAllocBW is AllocBW-V,
   freeBWAllocation(L, TempL, Services, Placement),
   assemble2((N1,N2,NewAllocBW), TempL, NewL).

toFree(N1,N2,B,Services,_) :- 
    member((S1,N1,_),Services), 
    s2s(S1,S2,_,B), member((S2,N2,_),Services). 
toFree(N1,N2,B,Services,P) :- 
    member((S1,N1,_),Services), s2s(S1,S2,_,B), 
    \+member((S2,N2,_),Services), member(on(S2,N2),P). 
toFree(N1,N2,B,Services,P) :- 
    member(on(S1,N1),P), 
    \+member((S1,N1,_),Services), s2s(S1,S2,_,B), member((S2,N2,_),Services).
 
sumLinkBWToFree([],0).
sumLinkBWToFree([B|Bs],V) :- sumLinkBWToFree(Bs,TempV), V is B+TempV.

assemble2((_,_,AllocatedBW), L, L) :- AllocatedBW =:= 0.
assemble2((N1,N2,AllocatedBW), L, [(N1,N2,AllocatedBW)|L]) :- AllocatedBW>0.