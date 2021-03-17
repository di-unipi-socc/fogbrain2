reasoningStep(App, Placement, AllocHW, AllocBW, Context, NewPlacement) :-
    appDiff(App, Placement, Context, ToAdd, ToRemove, ToUpdate, S2SToUpdate),!,
    cleanPlacement(ToRemove, ToUpdate, S2SToUpdate, Placement, PPlacement, AllocHW, PAllocHW, AllocBW, PAllocBW, Context),
    replacement(App, ToAdd, PPlacement, PAllocHW, PAllocBW, NewPlacement).

appDiff(App, Placement, Context, ToAdd, ToRemove, ToUpdate, S2SToUpdate) :-
    Context=(ContextServices,ContextS2S),
    serviceDiffs(App, Placement, ContextServices, ToAdd1, ToUpdate, ToRemove1),
    s2sDiffs(App, Placement, ContextServices, ContextS2S, ToAdd2, ToRemove2, S2SToUpdate),
    union(ToAdd1,ToAdd2,ToAdd), union(ToRemove1,ToRemove2,ToRemove).

serviceDiffs(App, Placement, ContextServices, ToAdd, ToUpdate, ToRemove) :-
    application(App, Services),
    changedServices(Services, Placement, ContextServices, ToAdd, ToUpdate, ToRemove).

changedServices([], Placement, ContextServices, [], [], ToRemove) :-
    removedServices(ContextServices,Placement,ToRemove).
changedServices([S|Services], Placement, ContextServices, NewToAdd, NewToUpdate, NewToRemove) :-
    changedServices(Services, Placement, ContextServices, TmpToAdd, TmpToUpdate, TmpToRemove),
    serviceDiff(S, Placement, ContextServices, Diff),
    sortService(Diff, ContextServices, TmpToAdd, TmpToUpdate, TmpToRemove, NewToAdd, NewToUpdate, NewToRemove).

removedServices([], _, []).
removedServices([service(S, SWReqs, HWReqs, TReqs)|CtxServices], Placement, [diff(S,N,(SWReqs, -HWReqs, TReqs))|Rest]) :-
    \+ service(S, _, _, _), member(on(S,N), Placement),
    removedServices(CtxServices, Placement, Rest).
removedServices([service(S, _, _, _)|CtxServices], Placement, Rest) :-
    service(S, _, _, _),
    removedServices(CtxServices, Placement, Rest).

serviceDiff(S, Placement, ContextServices, diff(S,N,(SWDiff,HWDiff,TDiff))) :-
    member(service(S, SWReqsOld, HWReqsOld, TReqsOld),ContextServices),
    service(S, SWReqs, HWReqs, TReqs),
    HWDiff is HWReqs - HWReqsOld,
    listDiff(SWReqsOld, SWReqs, SWDiff),
    listDiff(TReqsOld, TReqs, TDiff),
    (member(on(S,N),Placement); N=none).
serviceDiff(S, _, ContextServices, diff(S,none,(SWReqs,HWReqs,TReqs))) :-
    \+ member(service(S, _, _, _),ContextServices),
    service(S, SWReqs, HWReqs, TReqs).


sortService(diff(S,none,_), _, ToAdd, ToUpdate, ToRemove, [S|ToAdd], ToUpdate, ToRemove). 
sortService(diff(S,N,Diff), ContextServices, ToAdd, ToUpdate, ToRemove, [S|ToAdd], ToUpdate, [diff(S,N,(SWReqsOld,-HWReqsOld,TReqsOld))|ToRemove]) :- 
    dif(N,none), toMigrate(S,N,Diff), % Perhaps, we can split toMigrate from onSuffering nodes across 2 clauses of sortService
    member(service(S, SWReqsOld, HWReqsOld, TReqsOld),ContextServices). 
sortService(diff(S,N,D), _, ToAdd, ToUpdate, ToRemove, ToAdd, [diff(S,N,D)|ToUpdate], ToRemove) :- 
    dif(N,none), toUpdate(N,D).
sortService(diff(_,N,([],0,[])), _, ToAdd, ToUpdate, ToRemove, ToAdd, ToUpdate, ToRemove) :- 
    dif(N,none). %, \+ onSufferingNode(S,N)

toMigrate(S,N,Diff) :-
    (onChangedReqs(N,Diff); onSufferingNode(S,N)). % TODO: Perhaps, we can optimise these two predicates to avoid double-checks :-)

onSufferingNode(S, N) :-
    node(N, SWCaps, HWCaps, TCaps), 
    service(S, SWReqs, _, TReqs),
    hwTh(T), \+ (swReqsOK(SWReqs,SWCaps), HWCaps > T, thingReqsOK(TReqs,TCaps)).
onSufferingNode(_, N) :- 
    \+ node(N, _, _, _).

onChangedReqs(N,(SWDiff,HWDiff,TDiff)) :-
    (dif(SWDiff,[]); dif(HWDiff,0); dif(TDiff,[])),
    node(N, SWCaps, HWCaps, TCaps), 
    hwTh(T), \+ (swReqsOK(SWDiff, SWCaps), HWCaps > HWDiff + T, thingReqsOK(TDiff, TCaps)).

toUpdate(N,(SWDiff,HWDiff,TDiff)) :-
    (dif(SWDiff,[]); dif(HWDiff,0); dif(TDiff,[])),
    node(N, SWCaps, HWCaps, TCaps),
    swReqsOK(SWDiff, SWCaps), 
    hwTh(T), HWCaps > HWDiff + T, 
    thingReqsOK(TDiff, TCaps).

s2sDiffs(_, _, _, _, [], [], []).

/*
s2sDiffs(App, Placement, ContextServices, ContextS2S, ToAdd, ToRemove, S2SToUpdate):-
    appS2S(App, S2Ss),
    s2sDiffs(S2Ss, Placement, ContextServices, ContextS2S, ToAdd, ToRemove, S2SToUpdate1),
    findall(S2S, removedS2S(Placement, ContextS2S, S2S), S2SToRemove), union(S2SToUpdate1, S2SToRemove, S2SToUpdate).
 
appS2S(App,S2Ss) :-
    application(App, Services),
    findall(s2s(S1, S2, Lat, BW), (s2s(S1, S2, Lat, BW), member(S1,Services), member(S2,Services)), S2Ss).
 
s2sDiffs([], _, _, _, [], [], []).
s2sDiffs([S2S|S2Ss], Placement, ContextServices, ContextS2S, ToAdd, ToRemove, S2SToUpdate, NewToAdd, NewToRemove, NewS2SToUpdate) :- %s2s(S1, S2, ReqLat, ReqBW)
    s2sDiffs(S2Ss, Placement, ContextServices, ContextS2S, TmpToAdd, TmpToRemove, TmpS2SToUpdate),
    s2sDiff(S2S, Placement, ContextS2S, Diff),
    sortS2S(Diff, ContextServices, TmpToAdd, TmpToRemove, TmpS2SToUpdate, NewToAdd, NewToRemove, NewS2SToUpdate).
 
s2sDiff(s2s(S1, S2, ReqLat, ReqBW), Placement, ContextS2S, diff(S1,N1,S2,N2,((ReqLat, LatDiff),BWDiff))) :-
    member(s2s(S1, S2, OldReqLat, OldReqBW), ContextS2S),
    member(on(S1,N1),Placement), member(on(S2,N2),Placement), dif(N1,N2), 
    LatDiff is ReqLat - OldReqLat, BWDiff is ReqBW - OldReqBW.
s2sDiff(s2s(S1, S2, ReqLat, ReqBW), Placement, ContextS2S, diff(S1,N1,S2,N2,((ReqLat, 0),BWDiff))) :-
    \+ member(s2s(S1, S2, _, _), ContextS2S),
    (member(on(S1,N1),Placement); N1=none), 
    (member(on(S2,N2),Placement); N2=none). 
    % come fare dif se N1 e N2 entrambi non None
    % come distinguere un nuovo s2s con entrmabi i nodi non none da un update? (bisogna farlo?) */

removedS2S(Placement, ContextS2S, diff(S1,N1,S2,N2,(_,-BW))) :-
    member(s2s(S1, S2, _, BW), ContextS2S), \+s2s(S1, S2, _, _),
    member(on(S1,N1),Placement), member(on(S2,N2),Placement),
    dif(N1,N2).

replacement(A, [], Placement, AllocHW, AllocBW, Placement) :-
    writeln('ciao1'),
    retract(deployment(A, _, _, _, _)),
    deploy(A, Placement, AllocHW, AllocBW).

replacement(A, ServicesToPlace, Placement, AllocHW, AllocBW, NewPlacement) :-
    dif(ServicesToPlace,[]),
    placement(ServicesToPlace, AllocHW, NewAllocHW, AllocBW, NewAllocBW, Placement, NewPlacement),
    writeln('ciao2'),
    retract(deployment(A, _, _, _, _)),
    deploy(A, NewPlacement, NewAllocHW, NewAllocBW).

% S2SToAdd, S2SToUpdate e S2SToremove possono essere visti come un unica lista S2SToUpdate che viene calcolata in appDiff
cleanPlacement(ServicesToRemove, ServicesToUpdate, S2SToUpdate, Placement, PPlacement, AllocHW, PAllocHW, AllocBW, PAllocBW, Context) :-
    Context=(_,ContextS2S),
    getServices(ServicesToRemove, ToRemoveSs),
    s2ssToRemove(ToRemoveSs, Placement, ContextS2S, S2SToRemove),
    union(ServicesToRemove, ServicesToUpdate, ToClean), union(S2SToRemove, S2SToUpdate, S2SToClean), % come gestire s2s to remove e to update dello stesso s2s? merge che da priorità a to remove?
    changeResourceAllocations(ToClean, S2SToClean, AllocHW, PAllocHW, AllocBW, PAllocBW),
    partialPlacement(Placement, ToRemoveSs, PPlacement).

getServices(List, Services) :- findall(S, (member(diff(S,_,_),List)), Services).

s2ssToRemove(ServicesToRemove, Placement, ContextS2S, S2SToRemove) :-
    findall(S2S, s2sToRemove(ServicesToRemove, Placement, ContextS2S, S2S), S2SToRemove).

s2sToRemove(ServicesToRemove, Placement, ContextS2S, diff(S1,N1,S2,N2,((LA,0),-BW))) :-
    member(S1,ServicesToRemove), 
    member(s2s(S1, S2, LA, BW),ContextS2S),
    member(on(S1,N1),Placement),  member(on(S2,N2),Placement),
    dif(N1,N2).
s2sToRemove(ServicesToRemove, Placement, ContextS2S, diff(S2,N2,S1,N1,((LA,0),-BW))) :-
    member(S1,ServicesToRemove), 
    member(s2s(S2, S1, LA, BW),ContextS2S),
    member(on(S1,N1),Placement), member(on(S2,N2),Placement),
    dif(N1,N2).

partialPlacement([],_,[]).
partialPlacement([on(S,_)|P],Services,PPlacement) :-
    member(S,Services), partialPlacement(P,Services,PPlacement).
partialPlacement([on(S,N)|P],Services,[on(S,N)|PPlacement]) :-
    \+member(S,Services), partialPlacement(P,Services,PPlacement).

changeResourceAllocations(Services, S2S, AllocHW, NewAllocHW, AllocBW, NewAllocBW) :-
    changeHWAllocation(AllocHW, NewAllocHW, Services),
    changeBWAllocation(AllocBW, NewAllocBW, S2S).
 
changeHWAllocation([], [], _).
changeHWAllocation([(N,AllocHW)|L], NewL, Services) :-
    sumNodeHWDiff(N, Services, HWDiff),
    NewAllocHW is AllocHW + HWDiff, 
    changeHWAllocation(L, TempL, Services),
    assembleHW((N,NewAllocHW), TempL, NewL).

sumNodeHWDiff(_, [], 0).
sumNodeHWDiff(N, [diff(_,N,(_,HWDiff,_))|STMs], Tot) :- sumNodeHWDiff(N, STMs, HH), Tot is HWDiff+HH.
sumNodeHWDiff(N, [diff(_,N1,_)|STMs], H) :- dif(N,N1), sumNodeHWDiff(N, STMs, H).
 
assembleHW((_,NewAllocHW), L, L) :- NewAllocHW=:=0.
assembleHW((N, NewAllocHW), L, [(N,NewAllocHW)|L]) :- NewAllocHW>0.
 
changeBWAllocation([],[], _).
changeBWAllocation([(N1,N2,AllocBW)|L], NewL, S2S) :-
   sumLinkBWDiff(N1, N2, S2S, BWDiff), 
   NewAllocBW is AllocBW + BWDiff,
   changeBWAllocation(L, TempL, S2S),
   assembleBW((N1,N2,NewAllocBW), TempL, NewL).

sumLinkBWDiff(_, _, [], 0).
sumLinkBWDiff(N1, N2, [diff(_,N1,_,N2,(_,BWDiff))|STMs], Tot) :- sumLinkBWDiff(N1, N2, STMs, BB), Tot is BWDiff+BB.
sumLinkBWDiff(N1, N2, [diff(_,N2,_,N1,(_,BWDiff))|STMs], Tot) :- sumLinkBWDiff(N1, N2, STMs, BB), Tot is BWDiff+BB.
sumLinkBWDiff(N1, N2, [diff(_,N3,_,N4,_)|STMs], B) :- (dif(N1,N3);dif(N2,N4)), sumLinkBWDiff(N1, N2, STMs, B).

assembleBW((_,_,AllocatedBW), L, L) :- AllocatedBW = 0.
assembleBW((N1,N2,AllocatedBW), L, [(N1,N2,AllocatedBW)|L]) :- AllocatedBW>0.

listDiff(_,[],[]).
listDiff(L1,[L|Ls],Add) :- member(L,L1), listDiff(L1,Ls,Add).
listDiff(L1,[L|Ls],[L|Add]) :- \+ member(L,L1), listDiff(L1,Ls,Add).
