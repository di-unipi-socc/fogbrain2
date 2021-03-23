% reasoningStep(+AppId, +Placement, +AllocHW, +AllocBW, +Context, -NewPlacement)
% Given an AppId, its current Placement and the associated AllocHW and AllocBW, 
% and its deployment Context, it determines a NewPlacement via continuous reasoning.
reasoningStep(AppId, Placement, Alloc, Context, NewPlacement) :-
    appDiff(AppId, Placement, Context, ToAdd, ToRemove, ToUpdate, S2SToUpdate),
    cleanPlacement(ToRemove, ToUpdate, S2SToUpdate, Placement, PPlacement, Alloc, PAlloc),
    replacement(AppId, ToAdd, PPlacement, PAlloc, NewPlacement).

appDiff(AppId, Placement, Context, ToAdd, ToRemove, ToUpdate, S2SToUpdate) :-
    Context=(CtxServices,CtxS2S),
    serviceDiffs(AppId,Placement, CtxServices, ToAdd1, ToUpdate1, ToRemove1), %!,
    s2sDiffs(Placement, CtxServices, CtxS2S, ToAdd2, ToUpdate1, ToUpdate, ToRemove1, ToRemove2, S2SToUpdate), 
    union(ToAdd1,ToAdd2,ToAdd), union(ToRemove1,ToRemove2,ToRemove).

cleanPlacement(ToRemove, ToUpdate, S2SToUpdate, Placement, PPlacement, Alloc, PAlloc) :-
    changeResourceAllocations(ToUpdate, S2SToUpdate, Alloc, PAlloc),
    partialPlacement(Placement, ToRemove, PPlacement).

replacement(A, [], Placement, Alloc, Placement) :-
    retract(deployment(A, _, _, _)), deploy(A, Placement, Alloc).
replacement(A, ServicesToPlace, Placement, Alloc, NewPlacement) :-
    dif(ServicesToPlace,[]), retract(deployment(A, _, _, _)),
    placement(ServicesToPlace, Alloc, NewAlloc, Placement, NewPlacement),
    deploy(A, NewPlacement, NewAlloc).

serviceDiffs(AppId,Placement, CtxServices, ToAdd, ToUpdate, ToRemove) :-
    application(AppId, Services),
    changedServices(Services, Placement, CtxServices, ToAdd, ToUpdate, ToRemove).

changedServices([], Placement, CtxServices, [], ToUpdate, ToRemove) :- 
    removedServices(CtxServices, Placement, ToUpdate, ToRemove).
changedServices([S|Services], Placement, CtxServices, NewToAdd, NewToUpdate, NewToRemove) :-
    changedServices(Services, Placement, CtxServices, TmpToAdd, TmpToUpdate, TmpToRemove),
    serviceDiff(S, Placement, CtxServices, Diff),
    sortService(Diff, CtxServices, TmpToAdd, TmpToUpdate, TmpToRemove, NewToAdd, NewToUpdate, NewToRemove).

removedServices([], _, [], []).
removedServices([service(S, SWReqs, HWReqs, TReqs)|CtxServices], Placement, [diff(S,N,(SWReqs, -HWReqs, TReqs))|ToUpdateRest], [S|ToRemoveRest]) :-
    \+ service(S, _, _, _), member(on(S,N), Placement),
    removedServices(CtxServices, Placement, ToUpdateRest, ToRemoveRest).
removedServices([service(S, _, _, _)|CtxServices], Placement, ToUpdateRest, ToRemoveRest):-
    service(S, _, _, _),
    removedServices(CtxServices, Placement, ToUpdateRest, ToRemoveRest).

serviceDiff(S, Placement, CtxServices, diff(S,N,(SWReqs,HWDiff,TReqs))) :-
    member(service(S, _, HWReqsOld, _),CtxServices),
    service(S, SWReqs, HWReqs, TReqs),
    HWDiff is HWReqs - HWReqsOld,
    (member(on(S,N),Placement); N=none).
serviceDiff(S, _, CtxServices, diff(S,none,(SWReqs,HWReqs,TReqs))) :-
    \+ member(service(S, _, _, _),CtxServices),
    service(S, SWReqs, HWReqs, TReqs).

sortService(diff(S,none,_), _, ToAdd, ToUpdate, ToRemove, [S|ToAdd], ToUpdate, ToRemove).
sortService(diff(S,N,D), CtxServices, ToAdd, ToUpdate, ToRemove, [S|ToAdd], [diff(S,N,(SWReqsOld,-HWReqsOld,TReqsOld))|ToUpdate], [S|ToRemove]) :- 
    dif(N,none), serviceToMigrate(N, D, ToUpdate), 
    member(service(S, SWReqsOld, HWReqsOld, TReqsOld),CtxServices).
sortService(diff(S,N,D), _, ToAdd, ToUpdate, ToRemove, ToAdd, [diff(S,N,D)|ToUpdate], ToRemove) :- 
    dif(N,none), serviceToUpdate(N, D, ToUpdate).
sortService(diff(_,N,(_,0,_)), _, ToAdd, ToUpdate, ToRemove, ToAdd, ToUpdate, ToRemove) :- 
    dif(N,none). 

serviceToMigrate(N, (SWReqs,HWDiff,TReqs), ToUpdate) :-
    node(N, SWCaps, HWCaps, TCaps), 
    sumHWDiffs(N, ToUpdate, HWUpdate),
    hwTh(T), \+ (swReqsOK(SWReqs, SWCaps), HWCaps > HWUpdate + HWDiff + T, thingReqsOK(TReqs, TCaps)).
serviceToMigrate(N,_) :-
    \+ node(N, _, _, _).

serviceToUpdate(N,(SWReqs,HWDiff,TReqs), ToUpdate) :-
    HWDiff =\= 0, node(N, SWCaps, HWCaps, TCaps),
    sumHWDiffs(N, ToUpdate, HWUpdate),
    swReqsOK(SWReqs, SWCaps), 
    hwTh(T), HWCaps > HWUpdate + HWDiff + T, 
    thingReqsOK(TReqs, TCaps).

s2sDiffs(Placement, CtxServices, CtxS2S, SToAdd, ToUpdate1, ToUpdate, ToRemove1, SToRemove, S2SToUpdate):-
    appS2S(S2Ss), 
    changedS2S(S2Ss, Placement, CtxServices, CtxS2S, ToUpdate1, ToUpdate, ToRemove1, SToRemove, SToAdd, S2SToUpdate).

appS2S(S2Ss) :- findall((S1, S2, Lat, BW), (s2s(S1, S2, Lat, BW)), S2Ss).

changedS2S([], Placement, _, CtxS2S, ToUpdate, ToUpdate, ToRemove1, [], [], S2SToRemove) :-
    removedS2S(CtxS2S,Placement,ToRemove1,S2SToRemove).
changedS2S([(S1, S2, ReqLat, ReqBW)|S2Ss], Placement, CtxServices, CtxS2S, ToUpdate1, ToUpdate, ToRemove1, SToRemove, SToAdd, S2SToUpdate) :-
    changedS2S(S2Ss, Placement, CtxServices, CtxS2S, ToUpdate1, TmpToUpdate, ToRemove1, TmpSToRemove, TmpSToAdd, TmpS2SToUpdate),
    s2sDiff(S1, S2, ReqLat, ReqBW, Placement, CtxS2S, Diff),
    sortS2S(Diff, CtxServices, CtxS2S, TmpToUpdate, ToUpdate, TmpSToRemove, TmpSToAdd, TmpS2SToUpdate, SToRemove, SToAdd, S2SToUpdate).

removedS2S([], _, _, []).
removedS2S([s2s(S1, S2, _, ReqBW)|CtxS2Ss], Placement, ToRemove1, [diff(S1,N1,S2,N2,(_,-ReqBW))|Rest]) :-
    ( ( \+ s2s(S1, S2, _, _) ) ; ( member(S1,ToRemove1) ; member(S2,ToRemove1) ) ),
    member(on(S1,N1),Placement), member(on(S2,N2),Placement), dif(N1,N2),
    removedS2S(CtxS2Ss, Placement, ToRemove1, Rest).
removedS2S([s2s(S1, S2, _, _)|CtxS2Ss], Placement, ToRemove1, Rest) :-
    s2s(S1, S2, _, _),
    removedS2S(CtxS2Ss, Placement, ToRemove1, Rest).

s2sDiff(S1, S2, ReqLat, ReqBW, Placement, CtxS2S, diff(S1,N1,S2,N2,(ReqLat,BWDiff))) :-
    member(s2s(S1, S2, _, OldReqBW), CtxS2S), 
    member(on(S1,N1),Placement), member(on(S2,N2),Placement), dif(N1,N2), 
    BWDiff is ReqBW - OldReqBW.
s2sDiff(S1, S2, ReqLat, ReqBW, Placement, CtxS2S, diff(S1,N1,S2,N2,(ReqLat,ReqBW))) :-
    \+ member(s2s(S1, S2, _, _), CtxS2S), % new s2s
    member(on(S1,N1),Placement), member(on(S2,N2),Placement), dif(N1,N2). % already placed services
s2sDiff(S1, S2, _, _, Placement, CtxS2S, pass) :-
    \+ member(s2s(S1, S2, _, _), CtxS2S), % new s2s
    \+ (member(on(S1,_),Placement), member(on(S2,_),Placement)). % at least one non-placed service
s2sDiff(S1, S2, _, _, Placement, _, pass) :-
    member(on(S1,N1),Placement), member(on(S2,N2),Placement), N1=N2. %same node

sortS2S(D, _, _, ToUpdate, ToUpdate, SToRemove, SToAdd, S2SToUpdate, SToRemove, SToAdd, S2SToUpdate) :-
    D=pass; ( D = diff(S1,N1,S2,N2,_), member(diff(S1,N1,S2,N2,_), S2SToUpdate) ). % it's a pass or it's already to be removed fully
sortS2S(diff(S1,N1,S2,N2,Diff), _, _, ToUpdate, ToUpdate, SToRemove, SToAdd, S2SToUpdate, SToRemove, SToAdd, [diff(S1,N1,S2,N2,Diff)|S2SToUpdate]) :-
    \+ member(diff(S1,N1,S2,N2,_), S2SToUpdate), s2sToUpdate(N1,N2,Diff,S2SToUpdate).
sortS2S(diff(S1,N1,S2,N2,Diff), CtxServices, _, ToUpdate1, ToUpdate, SToRemove, SToAdd, S2SToUpdate, NewSToRemove, NewSToAdd, [diff(S1,N1,S2,N2,Diff)|S2SToUpdate]) :-
    \+ member(diff(S1,N1,S2,N2,_), S2SToUpdate), 
    s2sToReplace(N1,N2,Diff,S2SToUpdate),
    serviceDiff(S1, [on(S1,N1)], CtxServices, diff(_,_,(_,HWDiff1,_))), addDiff(S1,N1,HWDiff1,ToUpdate1,TmpToUpdate),
    serviceDiff(S2, [on(S2,N2)], CtxServices, diff(_,_,(_,HWDiff2,_))), addDiff(S2,N2,HWDiff2,TmpToUpdate,ToUpdate), 
    union([S1,S2],SToRemove,NewSToRemove), union([S1,S2],SToAdd,NewSToAdd).
sortS2S(D, _, _, ToUpdate, ToUpdate, SToRemove, SToAdd, S2SToUpdate, SToRemove, SToAdd, S2SToUpdate) :-
    D = diff(_,_,_,_,(_,BWDiff)), BWDiff =:= 0. %LatDiff =:= 0

s2sToUpdate(N1,N2,(ReqLat,BWDiff),S2SToUpdate):-
    BWDiff =\= 0,
    sumBWDiffs(N1,N2,S2SToUpdate,BWUpdate),
    link(N1,N2,FeatLat,FeatBW),
    FeatLat =< ReqLat, bwTh(T), FeatBW >= BWUpdate + BWDiff + T.

s2sToReplace(N1,N2,(ReqLat,BWDiff),S2SToUpdate):- 
    link(N1,N2,FeatLat,FeatBW),
    sumBWDiffs(N1,N2,S2SToUpdate,BWUpdate),
    bwTh(T), \+ (FeatLat =< ReqLat, FeatBW >= BWUpdate + BWDiff + T).
s2sToReplace(N1,N2,_, _):-
    \+ link(N1,N2,_,_).

changeResourceAllocations(ToClean, S2S, (AllocHW, AllocBW), (NewAllocHW, NewAllocBW)) :-
    changeHWAllocation(AllocHW, NewAllocHW, ToClean),
    changeBWAllocation(AllocBW, NewAllocBW, S2S).
 
changeHWAllocation(A, A, []).
changeHWAllocation([], [], _).
changeHWAllocation([(N,AllocHW)|L], NewL, ToUpdate) :-
    sumHWDiffs(N,ToUpdate,HWDiff),
    NewAllocHW is AllocHW + HWDiff, 
    changeHWAllocation(L, TempL, ToUpdate),
    assembleHW((N,NewAllocHW), TempL, NewL).

changeBWAllocation(A, A, []). 
changeBWAllocation([],[], _).
changeBWAllocation([(N1,N2,AllocBW)|L], NewL, S2S) :-
   sumBWDiffs(N1, N2, S2S, BWDiff), 
   NewAllocBW is AllocBW + BWDiff,
   changeBWAllocation(L, TempL, S2S),
   assembleBW((N1,N2,NewAllocBW), TempL, NewL).

partialPlacement(P,[],P).
partialPlacement([],_,[]).
partialPlacement([on(S,_)|P],Services,PPlacement) :-
    member(S,Services), partialPlacement(P,Services,PPlacement).
partialPlacement([on(S,N)|P],Services,[on(S,N)|PPlacement]) :-
    \+member(S,Services), partialPlacement(P,Services,PPlacement).
 
assembleHW((_,NewAllocHW), L, L) :- NewAllocHW=:=0.
assembleHW((N, NewAllocHW), L, [(N,NewAllocHW)|L]) :- NewAllocHW>0.

sumHWDiffs(N, ToUpdate, HWUpdate) :-
    findall(HW, member(diff(_,N,(_,HW,_)), ToUpdate), HWDiffs),
    sum_list(HWDiffs, HWUpdate).

sumBWDiffs(N1,N2,S2SToUpdate,BWUpdate) :-
    findall(BW, member(diff(_,N1,_,N2,(_,BW)), S2SToUpdate), BWDiffs),
    sum_list(BWDiffs, BWUpdate).

assembleBW((_,_,AllocatedBW), L, L) :- AllocatedBW =:= 0.
assembleBW((N1,N2,AllocatedBW), L, [(N1,N2,AllocatedBW)|L]) :- AllocatedBW>0.

addDiff(S1, N1, HWDiff, ToUpdate, [Diff|NewToUpdate]) :-
    member((S1,N1,OldHWDiff),ToUpdate),
    MinHWDiff is min(HWDiff, OldHWDiff),
    Diff=diff(S1,N1,MinHWDiff),
    delete(ToUpdate,(S1,N1,OldHWDiff),NewToUpdate).
addDiff(S1, N1, HWDiff, ToUpdate, [diff(S1,N1,HWDiff)|ToUpdate]) :-
    \+ member((S1,N1,_),ToUpdate).