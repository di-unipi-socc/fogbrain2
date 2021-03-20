% reasoningStep(+AppId, +Placement, +AllocHW, +AllocBW, +Context, -NewPlacement)
% Given an AppId, its current Placement and the associated AllocHW and AllocBW, 
% and its deployment Context, it determines a NewPlacement via continuous reasoning.
reasoningStep(AppId, Placement, AllocHW, AllocBW, Context, NewPlacement) :-
    appDiff(AppId, Placement, Context, ToAdd, ToRemove, ToUpdate, S2SToUpdate),
    cleanPlacement(ToRemove, ToUpdate, S2SToUpdate, Placement, PPlacement, AllocHW, PAllocHW, AllocBW, PAllocBW),
    replacement(AppId, ToAdd, PPlacement, PAllocHW, PAllocBW, NewPlacement).

appDiff(AppId, Placement, Context, ToAdd, ToRemove, ToUpdate, S2SToUpdate) :-
    Context=(CtxServices,CtxS2S),
    serviceDiffs(AppId,Placement, CtxServices, ToAdd1, ToUpdate, ToRemove1),
    s2sDiffs(Placement, CtxServices, CtxS2S, ToAdd2, ToRemove1, ToRemove2, S2SToUpdate), 
    union(ToAdd1,ToAdd2,ToAdd), union(ToRemove1,ToRemove2,ToRemove).

cleanPlacement(ToRemove, ToUpdate, S2SToUpdate, Placement, PPlacement, AllocHW, PAllocHW, AllocBW, PAllocBW) :-
    getServiceIDs(ToRemove, ToRemoveSIDs),
    union(ToUpdate, ToRemove, ToClean),
    changeResourceAllocations(ToClean, S2SToUpdate, AllocHW, PAllocHW, AllocBW, PAllocBW),
    partialPlacement(Placement, ToRemoveSIDs, PPlacement).

replacement(A, [], Placement, AllocHW, AllocBW, Placement) :-
    retract(deployment(A, _, _, _, _)), deploy(A, Placement, AllocHW, AllocBW).
replacement(A, ServicesToPlace, Placement, AllocHW, AllocBW, NewPlacement) :-
    dif(ServicesToPlace,[]), retract(deployment(A, _, _, _, _)),
    placement(ServicesToPlace, AllocHW, NewAllocHW, AllocBW, NewAllocBW, Placement, NewPlacement),
    deploy(A, NewPlacement, NewAllocHW, NewAllocBW).

serviceDiffs(AppId,Placement, CtxServices, ToAdd, ToUpdate, ToRemove) :-
    application(AppId, Services),
    changedServices(Services, Placement, CtxServices, ToAdd, ToUpdate, ToRemove).

changedServices([], Placement, CtxServices, [], [], ToRemove) :-
    removedServices(CtxServices,Placement,ToRemove).
changedServices([S|Services], Placement, CtxServices, NewToAdd, NewToUpdate, NewToRemove) :-
    changedServices(Services, Placement, CtxServices, TmpToAdd, TmpToUpdate, TmpToRemove),
    serviceDiff(S, Placement, CtxServices, Diff),
    sortService(Diff, CtxServices, TmpToAdd, TmpToUpdate, TmpToRemove, NewToAdd, NewToUpdate, NewToRemove).

removedServices([], _, []).
removedServices([service(S, SWReqs, HWReqs, TReqs)|CtxServices], Placement, [diff(S,N,(SWReqs, -HWReqs, TReqs))|Rest]) :-
    \+ service(S, _, _, _), member(on(S,N), Placement),
    removedServices(CtxServices, Placement, Rest).
removedServices([service(S, _, _, _)|CtxServices], Placement, Rest) :-
    service(S, _, _, _),
    removedServices(CtxServices, Placement, Rest).

serviceDiff(S, Placement, CtxServices, diff(S,N,(SWDiff,HWDiff,TDiff))) :-
    member(service(S, SWReqsOld, HWReqsOld, TReqsOld),CtxServices),
    service(S, SWReqs, HWReqs, TReqs),
    HWDiff is HWReqs - HWReqsOld,
    listDiff(SWReqsOld, SWReqs, SWDiff),
    listDiff(TReqsOld, TReqs, TDiff),
    (member(on(S,N),Placement); N=none).
serviceDiff(S, _, CtxServices, diff(S,none,(SWReqs,HWReqs,TReqs))) :-
    \+ member(service(S, _, _, _),CtxServices),
    service(S, SWReqs, HWReqs, TReqs).

sortService(diff(S,none,_), _, ToAdd, ToUpdate, ToRemove, [S|ToAdd], ToUpdate, ToRemove). 
sortService(diff(S,N,Diff), CtxServices, ToAdd, ToUpdate, ToRemove, [S|ToAdd], ToUpdate, [diff(S,N,(SWReqsOld,-HWReqsOld,TReqsOld))|ToRemove]) :- 
    dif(N,none), toMigrate(S,N,Diff), 
    member(service(S, SWReqsOld, HWReqsOld, TReqsOld),CtxServices). 
sortService(diff(S,N,D), _, ToAdd, ToUpdate, ToRemove, ToAdd, [diff(S,N,D)|ToUpdate], ToRemove) :- 
    dif(N,none), toUpdate(N,D).
sortService(diff(_,N,([],0,[])), _, ToAdd, ToUpdate, ToRemove, ToAdd, ToUpdate, ToRemove) :- 
    dif(N,none). 

toMigrate(S,N,Diff) :- (requirementsProblem(N,Diff); nodeProblem(S,N)).

requirementsProblem(N,(SWDiff,HWDiff,TDiff)) :-
    (dif(SWDiff,[]); HWDiff =\= 0; dif(TDiff,[])),
    node(N, SWCaps, HWCaps, TCaps), 
    hwTh(T), \+ (swReqsOK(SWDiff, SWCaps), HWCaps > HWDiff + T, thingReqsOK(TDiff, TCaps)).

nodeProblem(S, N) :-
    node(N, SWCaps, HWCaps, TCaps), 
    service(S, SWReqs, _, TReqs),
    hwTh(T), \+ (swReqsOK(SWReqs,SWCaps), HWCaps > T, thingReqsOK(TReqs,TCaps)).
nodeProblem(_, N) :- 
    \+ node(N, _, _, _).

toUpdate(N,(SWDiff,HWDiff,TDiff)) :-
    (dif(SWDiff,[]); HWDiff =\= 0; dif(TDiff,[])),
    node(N, SWCaps, HWCaps, TCaps),
    swReqsOK(SWDiff, SWCaps), 
    hwTh(T), HWCaps > HWDiff + T, 
    thingReqsOK(TDiff, TCaps).

s2sDiffs(Placement, CtxServices, CtxS2S, SToAdd, ToRemove1, SToRemove, S2SToUpdate):-
    appS2S(S2Ss), 
    changedS2S(S2Ss, Placement, CtxServices, CtxS2S, ToRemove1, SToRemove, SToAdd, S2SToUpdate).

appS2S(S2Ss) :- findall((S1, S2, Lat, BW), (s2s(S1, S2, Lat, BW)), S2Ss).

changedS2S([], Placement, _, CtxS2S, ToRemove1, [], [], S2SToRemove) :-
    removedS2S(CtxS2S,Placement,ToRemove1,S2SToRemove).
changedS2S([(S1, S2, ReqLat, ReqBW)|S2Ss], Placement, CtxServices, CtxS2S, ToRemove1, SToRemove, SToAdd, S2SToUpdate) :-
    changedS2S(S2Ss, Placement, CtxServices, CtxS2S, ToRemove1, TmpSToRemove, TmpSToAdd, TmpS2SToUpdate),
    s2sDiff(S1, S2, ReqLat, ReqBW, Placement, CtxS2S, Diff),
    sortS2S(Diff, CtxServices, CtxS2S, TmpSToRemove, TmpSToAdd, TmpS2SToUpdate, SToRemove, SToAdd, S2SToUpdate).

removedS2S([], _, _, []).
removedS2S([s2s(S1, S2, _, ReqBW)|CtxS2Ss], Placement, ToRemove1, [diff(S1,N1,S2,N2,((_,0),-ReqBW))|Rest]) :-
    ( ( \+ s2s(S1, S2, _, _) ) ; ( member(diff(S1,_,_),ToRemove1) ; member(diff(S2,_,_),ToRemove1) ) ),
    member(on(S1,N1),Placement), member(on(S2,N2),Placement), dif(N1,N2),
    removedS2S(CtxS2Ss, Placement, ToRemove1, Rest).
removedS2S([s2s(S1, S2, _, _)|CtxS2Ss], Placement, ToRemove1, Rest) :-
    s2s(S1, S2, _, _),
    removedS2S(CtxS2Ss, Placement, ToRemove1, Rest).

s2sDiff(S1, S2, ReqLat, ReqBW, Placement, CtxS2S, diff(S1,N1,S2,N2,((ReqLat, LatDiff),BWDiff))) :-
    member(s2s(S1, S2, OldReqLat, OldReqBW), CtxS2S), 
    member(on(S1,N1),Placement), member(on(S2,N2),Placement), dif(N1,N2), 
    LatDiff is ReqLat - OldReqLat, BWDiff is ReqBW - OldReqBW.
s2sDiff(S1, S2, ReqLat, ReqBW, Placement, CtxS2S, diff(S1,N1,S2,N2,((ReqLat, ReqLat),ReqBW))) :-
    \+ member(s2s(S1, S2, _, _), CtxS2S), % new s2s
    member(on(S1,N1),Placement), member(on(S2,N2),Placement), dif(N1,N2). % already placed services
s2sDiff(S1, S2, _, _, Placement, CtxS2S, pass) :-
    \+ member(s2s(S1, S2, _, _), CtxS2S), % new s2s
    \+ (member(on(S1,_),Placement), member(on(S2,_),Placement)). % at least one non-placed service

sortS2S(D, _, _, SToRemove, SToAdd, S2SToUpdate, SToRemove, SToAdd, S2SToUpdate) :-
    D=pass; ( D = diff(S1,N1,S2,N2,_), member(diff(S1,N1,S2,N2,_), S2SToUpdate) ). % it's a pass or it's already to be removed fully
sortS2S(diff(S1,N1,S2,N2,Diff), _, _, SToRemove, SToAdd, S2SToUpdate, SToRemove, SToAdd, [diff(S1,N1,S2,N2,Diff)|S2SToUpdate]) :-
    \+ member(diff(S1,N1,S2,N2,_), S2SToUpdate), toUpdate(N1,N2,Diff).
sortS2S(diff(S1,N1,S2,N2,Diff), CtxServices, _, SToRemove, SToAdd, S2SToUpdate, NewSToRemove, NewSToAdd, [diff(S1,N1,S2,N2,Diff)|S2SToUpdate]) :-
    \+ member(diff(S1,N1,S2,N2,_), S2SToUpdate), toReplace(S1,N1,S2,N2,Diff),
    serviceDiff(S1, [on(S1,N1)], CtxServices, Diff1), serviceDiff(S2, [on(S2,N2)], CtxServices, Diff2),
    append(Diff1,SToRemove,Tmp1), union(Diff2,Tmp1,NewSToRemove),
    append(S1,SToAdd,Tmp2), union(S2,Tmp2,NewSToAdd).
sortS2S(D, _, _, SToRemove, SToAdd, S2SToUpdate, SToRemove, SToAdd, S2SToUpdate) :-
    D = diff(_,_,_,_,((_, LatDiff),BWDiff)), LatDiff =:= 0, BWDiff =:= 0.

toUpdate(N1,N2,((ReqLat, LatDiff),BWDiff)):-
    (LatDiff =\= 0; BWDiff =\= 0),
    link(N1,N2,FeatLat,FeatBW),
    FeatLat =< ReqLat, bwTh(T), FeatBW >= T + BWDiff.

toReplace(S1,N1,S2,N2,Diff) :- (requirementsProblem(N1,N2,Diff); linkProblem(S1,N1,S2,N2)).

requirementsProblem(N1,N2,((ReqLat, LatDiff),BWDiff)) :-
    (LatDiff =\= 0; BWDiff =\= 0),
    link(N1,N2,FeatLat,FeatBW),
    bwTh(T), \+ (FeatLat =< ReqLat, FeatBW >= T + BWDiff).

linkProblem(S1,N1,S2,N2) :-
    link(N1,N2,FeatLat,FeatBW),
    s2s(S1,S2,ReqLat, _),
    bwTh(T), \+ (FeatLat =< ReqLat, FeatBW >= T).
linkProblem(_,N1,_,N2) :-
    \+ link(N1,N2,_,_).

/*
toReplace(N1,N2,((ReqLat, _),BWDiff)):- 
    %(dif(LatDiff,0); dif(BWDiff,0)),
    link(N1,N2,FeatLat,FeatBW),
    FeatLat > ReqLat, bwTh(T), FeatBW < T + BWDiff.
toReplace(N1,N2,_):-
    \+ link(N1,N2,_,_).
*/

changeResourceAllocations(ToClean, S2S, AllocHW, NewAllocHW, AllocBW, NewAllocBW) :-
    changeHWAllocation(AllocHW, NewAllocHW, ToClean),
    changeBWAllocation(AllocBW, NewAllocBW, S2S).
 
changeHWAllocation(A, A, []).
changeHWAllocation([], [], _).
changeHWAllocation([(N,AllocHW)|L], NewL, Services) :-
    sumNodeHWDiff(N, Services, HWDiff),
    NewAllocHW is AllocHW + HWDiff, 
    changeHWAllocation(L, TempL, Services),
    assembleHW((N,NewAllocHW), TempL, NewL).

changeBWAllocation(A, A, []). 
changeBWAllocation([],[], _).
changeBWAllocation([(N1,N2,AllocBW)|L], NewL, S2S) :-
   sumLinkBWDiff(N1, N2, S2S, BWDiff), 
   NewAllocBW is AllocBW + BWDiff,
   changeBWAllocation(L, TempL, S2S),
   assembleBW((N1,N2,NewAllocBW), TempL, NewL).

partialPlacement(P,[],P).
partialPlacement([],_,[]).
partialPlacement([on(S,_)|P],Services,PPlacement) :-
    member(S,Services), partialPlacement(P,Services,PPlacement).
partialPlacement([on(S,N)|P],Services,[on(S,N)|PPlacement]) :-
    \+member(S,Services), partialPlacement(P,Services,PPlacement).

getServiceIDs(List, Services) :- findall(S, (member(diff(S,_,_),List)), Services).

sumNodeHWDiff(_, [], 0).
sumNodeHWDiff(N, [diff(_,N,(_,HWDiff,_))|STMs], Tot) :- sumNodeHWDiff(N, STMs, HH), Tot is HWDiff+HH.
sumNodeHWDiff(N, [diff(_,N1,_)|STMs], H) :- dif(N,N1), sumNodeHWDiff(N, STMs, H).
 
assembleHW((_,NewAllocHW), L, L) :- NewAllocHW=:=0.
assembleHW((N, NewAllocHW), L, [(N,NewAllocHW)|L]) :- NewAllocHW>0.
 
sumLinkBWDiff(_, _, [], 0).
sumLinkBWDiff(N1, N2, [diff(_,N1,_,N2,(_,BWDiff))|STMs], Tot) :- sumLinkBWDiff(N1, N2, STMs, BB), Tot is BWDiff+BB.
% TODO: DOUBLECHECK THE CLAUSE BELOW: not sure it is needed here
%sumLinkBWDiff(N1, N2, [diff(_,N2,_,N1,(_,BWDiff))|STMs], Tot) :- sumLinkBWDiff(N1, N2, STMs, BB), Tot is BWDiff+BB. 
sumLinkBWDiff(N1, N2, [diff(_,N3,_,N4,_)|STMs], B) :- (dif(N1,N3);dif(N2,N4)), sumLinkBWDiff(N1, N2, STMs, B).

assembleBW((_,_,AllocatedBW), L, L) :- AllocatedBW =:= 0.
assembleBW((N1,N2,AllocatedBW), L, [(N1,N2,AllocatedBW)|L]) :- AllocatedBW>0.

listDiff(_,[],[]).
listDiff(L1,[L|Ls],Add) :- member(L,L1), listDiff(L1,Ls,Add).
listDiff(L1,[L|Ls],[L|Add]) :- \+ member(L,L1), listDiff(L1,Ls,Add).