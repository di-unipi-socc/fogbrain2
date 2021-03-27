continuousReasoning(AppId, Placement, Alloc, Ctx, NewPlacement) :-
    appDiffs(AppId, Placement, Ctx, SToAdd, SToRemove, HWDiffs, BWDiffs),
    cleanDeployment(SToRemove, HWDiffs, BWDiffs, Placement, PPlacement, Alloc, PAlloc),
    replacement(AppId, SToAdd, PPlacement, PAlloc, NewPlacement).

appDiffs(AppId, Placement, Ctx, SToAdd, SToRemove, HWDiffs, BWDiffs) :-
    serviceDiffs(AppId, Placement, Ctx, SToAdd1, HWDiffs1, SToRemove1),
    s2sDiffs(Placement, Ctx, SToAdd2, HWDiffs1, HWDiffs, SToRemove1, SToRemove2, BWDiffs), 
    union(SToAdd1,SToAdd2,SToAdd), union(SToRemove1,SToRemove2,SToRemove).

cleanDeployment(SToRemove, HWDiffs, BWDiffs, Placement, PPlacement, Alloc, PAlloc) :-
    cleanResourceAllocation(HWDiffs, BWDiffs, Alloc, PAlloc),
    cleanPlacement(Placement, SToRemove, PPlacement).

replacement(A, [], Placement, Alloc, Placement) :-
    retract(deployment(A, _, _, _)), deploy(A, Placement, Alloc).
replacement(A, ServicesToPlace, Placement, Alloc, NewPlacement) :-
    dif(ServicesToPlace,[]), retract(deployment(A, _, _, _)),
    placement(ServicesToPlace, Alloc, NewAlloc, Placement, NewPlacement),
    deploy(A, NewPlacement, NewAlloc).

serviceDiffs(AppId, Placement, Ctx, SToAdd, HWDiffs, SToRemove) :-
    application(AppId, Services), Ctx=(CtxServices,_),
    changedServices(Services, Placement, CtxServices, SToAdd, HWDiffs, SToRemove).

changedServices([], Placement, CtxServices, [], HWDiffs, SToRemove) :- 
    removedServices(CtxServices, Placement, HWDiffs, SToRemove).
changedServices([S|Services], Placement, CtxServices, NewSToAdd, NewHWDiffs, NewSToRemove) :-
    changedServices(Services, Placement, CtxServices, TmpSToAdd, TmpHWDiffs, TmpSToRemove),
    serviceDiff(S, Placement, CtxServices, Diff),
    sortService(Diff, CtxServices, TmpSToAdd, TmpHWDiffs, TmpSToRemove, NewSToAdd, NewHWDiffs, NewSToRemove).

removedServices([], _, [], []).
removedServices([service(S, SWReqs, HWReqs, TReqs)|CtxServices], Placement, [diff(S,N,(SWReqs, -HWReqs, TReqs))|HWDiffsRest], [S|SToRemoveRest]) :-
    \+ service(S, _, _, _), member(on(S,N), Placement),
    removedServices(CtxServices, Placement, HWDiffsRest, SToRemoveRest).
removedServices([service(S, _, _, _)|CtxServices], Placement, HWDiffsRest, SToRemoveRest):-
    service(S, _, _, _),
    removedServices(CtxServices, Placement, HWDiffsRest, SToRemoveRest).

serviceDiff(S, Placement, CtxServices, diff(S,N,(SWReqs,HWDiff,TReqs))) :-
    member(service(S, _, HWReqsOld, _),CtxServices),
    service(S, SWReqs, HWReqs, TReqs),
    HWDiff is HWReqs - HWReqsOld,
    (member(on(S,N),Placement); N=none).
serviceDiff(S, _, CtxServices, diff(S,none,(SWReqs,HWReqs,TReqs))) :-
    \+ member(service(S, _, _, _),CtxServices),
    service(S, SWReqs, HWReqs, TReqs).

sortService(diff(S,none,_), _, SToAdd, HWDiffs, SToRemove, [S|SToAdd], HWDiffs, SToRemove).
sortService(diff(S,N,D), CtxServices, SToAdd, HWDiffs, SToRemove, [S|SToAdd], [diff(S,N,(SWReqsOld,-HWReqsOld,TReqsOld))|HWDiffs], [S|SToRemove]) :- 
    dif(N,none), serviceToMigrate(N, D, HWDiffs), 
    member(service(S, SWReqsOld, HWReqsOld, TReqsOld),CtxServices).
sortService(diff(S,N,D), _, SToAdd, HWDiffs, SToRemove, SToAdd, [diff(S,N,D)|HWDiffs], SToRemove) :- 
    dif(N,none), serviceToUpdate(N, D, HWDiffs).
sortService(diff(_,N,(_,0,_)), _, SToAdd, HWDiffs, SToRemove, SToAdd, HWDiffs, SToRemove) :- 
    dif(N,none). 

serviceToMigrate(N, (SWReqs,HWDiff,TReqs), HWDiffs) :-
    node(N, SWCaps, HWCaps, TCaps), 
    sumHWDiffs(N, HWDiffs, HWUpdate),
    hwTh(T), \+ (swReqsOK(SWReqs, SWCaps), HWCaps > HWUpdate + HWDiff + T, thingReqsOK(TReqs, TCaps)).
serviceToMigrate(N,_) :-
    \+ node(N, _, _, _).

serviceToUpdate(N,(SWReqs,HWDiff,TReqs), HWDiffs) :-
    HWDiff =\= 0, node(N, SWCaps, HWCaps, TCaps),
    sumHWDiffs(N, HWDiffs, HWUpdate),
    swReqsOK(SWReqs, SWCaps), 
    hwTh(T), HWCaps > HWUpdate + HWDiff + T, 
    thingReqsOK(TReqs, TCaps).

s2sDiffs(Placement, Ctx, SToAdd, HWDiffs1, HWDiffs, SToRemove1, SToRemove, BWDiffs):-
    Ctx = (CtxServices, CtxS2S), 
    findall((S1, S2, Lat, BW), (s2s(S1, S2, Lat, BW)), S2Ss), 
    changedS2S(S2Ss, Placement, CtxServices, CtxS2S, HWDiffs1, HWDiffs, SToRemove1, SToRemove, SToAdd, BWDiffs).

changedS2S([], Placement, _, CtxS2S, HWDiffs, HWDiffs, SToRemove1, [], [], S2SToRemove) :-
    removedS2S(CtxS2S,Placement,SToRemove1,S2SToRemove).
changedS2S([(S1, S2, ReqLat, ReqBW)|S2Ss], Placement, CtxServices, CtxS2S, HWDiffs1, HWDiffs, SToRemove1, SToRemove, SToAdd, BWDiffs) :-
    changedS2S(S2Ss, Placement, CtxServices, CtxS2S, HWDiffs1, TmpHWDiffs, SToRemove1, TmpSToRemove, TmpSToAdd, TmpBWDiffs),
    s2sDiff(S1, S2, ReqLat, ReqBW, Placement, CtxS2S, Diff),
    sortS2S(Diff, CtxServices, CtxS2S, TmpHWDiffs, HWDiffs, TmpSToRemove, TmpSToAdd, TmpBWDiffs, SToRemove, SToAdd, BWDiffs).

removedS2S([], _, _, []).
removedS2S([s2s(S1, S2, _, ReqBW)|CtxS2Ss], Placement, SToRemove1, [diff(S1,N1,S2,N2,(_,-ReqBW))|Rest]) :-
    ( ( \+ s2s(S1, S2, _, _) ) ; ( member(S1,SToRemove1) ; member(S2,SToRemove1) ) ),
    member(on(S1,N1),Placement), member(on(S2,N2),Placement), dif(N1,N2),
    removedS2S(CtxS2Ss, Placement, SToRemove1, Rest).
removedS2S([s2s(S1, S2, _, _)|CtxS2Ss], Placement, SToRemove1, Rest) :-
    (s2s(S1, S2, _, _); (member(on(S1,N),Placement), member(on(S2,N),Placement)) ),
    removedS2S(CtxS2Ss, Placement, SToRemove1, Rest).

s2sDiff(S1, S2, ReqLat, ReqBW, Placement, CtxS2S, diff(S1,N1,S2,N2,(ReqLat,BWDiff))) :-
    member(s2s(S1, S2, _, OldReqBW), CtxS2S), 
    member(on(S1,N1),Placement), member(on(S2,N2),Placement), dif(N1,N2), 
    BWDiff is ReqBW - OldReqBW.
s2sDiff(S1, S2, ReqLat, ReqBW, Placement, CtxS2S, diff(S1,N1,S2,N2,(ReqLat,ReqBW))) :-
    \+ member(s2s(S1, S2, _, _), CtxS2S), % new s2s
    member(on(S1,N1),Placement), member(on(S2,N2),Placement), dif(N1,N2). % already placed services
s2sDiff(S1, S2, _, _, Placement, _, pass) :-
   ( \+ (member(on(S1,_),Placement), member(on(S2,_),Placement)) ) ; % new s2s: at least one non-placed service  \+ member(s2s(S1, S2, _, _), CtxS2S),
   ( member(on(S1,N1),Placement), member(on(S2,N2),Placement), N1=N2 ).  % same node   

sortS2S(D, _, _, HWDiffs, HWDiffs, SToRemove, SToAdd, BWDiffs, SToRemove, SToAdd, BWDiffs) :-
    D=pass; ( D = diff(S1,N1,S2,N2,_), member(diff(S1,N1,S2,N2,_), BWDiffs) ). % it's a pass or it's already to be removed fully
sortS2S(diff(S1,N1,S2,N2,Diff), _, _, HWDiffs, HWDiffs, SToRemove, SToAdd, BWDiffs, SToRemove, SToAdd, [diff(S1,N1,S2,N2,Diff)|BWDiffs]) :-
    \+ member(diff(S1,N1,S2,N2,_), BWDiffs), s2sToUpdate(N1,N2,Diff,BWDiffs).
sortS2S(diff(S1,N1,S2,N2,Diff), CtxServices, _, HWDiffs1, HWDiffs, SToRemove, SToAdd, BWDiffs, NewSToRemove, NewSToAdd, [diff(S1,N1,S2,N2,Diff)|BWDiffs]) :-
    \+ member(diff(S1,N1,S2,N2,_), BWDiffs), 
    s2sToReplace(N1,N2,Diff,BWDiffs),
    serviceDiff(S1, [on(S1,N1)], CtxServices, diff(_,_,(_,HWDiff1,_))), assembleDiff(S1,N1,HWDiff1,HWDiffs1,TmpHWDiffs),
    serviceDiff(S2, [on(S2,N2)], CtxServices, diff(_,_,(_,HWDiff2,_))), assembleDiff(S2,N2,HWDiff2,TmpHWDiffs,HWDiffs), 
    union([S1,S2],SToRemove,NewSToRemove), union([S1,S2],SToAdd,NewSToAdd).
sortS2S(D, _, _, HWDiffs, HWDiffs, SToRemove, SToAdd, BWDiffs, SToRemove, SToAdd, BWDiffs) :-
    D = diff(_,_,_,_,(_,BWDiff)), BWDiff =:= 0. %LatDiff =:= 0

s2sToUpdate(N1,N2,(ReqLat,BWDiff),BWDiffs):-
    BWDiff =\= 0,
    sumBWDiffs(N1,N2,BWDiffs,BWUpdate),
    link(N1,N2,FeatLat,FeatBW),
    FeatLat =< ReqLat, bwTh(T), FeatBW >= BWUpdate + BWDiff + T.

s2sToReplace(N1,N2,(ReqLat,BWDiff),BWDiffs):- 
    link(N1,N2,FeatLat,FeatBW),
    sumBWDiffs(N1,N2,BWDiffs,BWUpdate),
    bwTh(T), \+ (FeatLat =< ReqLat, FeatBW >= BWUpdate + BWDiff + T).
s2sToReplace(N1,N2,_, _):-
    \+ link(N1,N2,_,_).

cleanResourceAllocation(HWDiffs, BWDiffs, (AllocHW, AllocBW), (NewAllocHW, NewAllocBW)) :-
    cleanHWAllocation(AllocHW, NewAllocHW, HWDiffs),
    cleanBWAllocation(AllocBW, NewAllocBW, BWDiffs).

cleanHWAllocation(A, A, []).
cleanHWAllocation([], [], _).
cleanHWAllocation([(N,AllocHW)|L], NewL, HWDiffs) :-
    sumHWDiffs(N,HWDiffs,HWDiff),
    NewAllocHW is AllocHW + HWDiff, 
    cleanHWAllocation(L, TempL, HWDiffs),
    assembleHW((N,NewAllocHW), TempL, NewL).

cleanBWAllocation(A, A, []). 
cleanBWAllocation([],[], _).
cleanBWAllocation([(N1,N2,AllocBW)|L], NewL, S2S) :-
   sumBWDiffs(N1, N2, S2S, BWDiff), 
   NewAllocBW is AllocBW + BWDiff,
   cleanBWAllocation(L, TempL, S2S),
   assembleBW((N1,N2,NewAllocBW), TempL, NewL).

cleanPlacement(P,[],P).
cleanPlacement([],_,[]).
cleanPlacement([on(S,_)|P],Services,PPlacement) :-
    member(S,Services), cleanPlacement(P,Services,PPlacement).
cleanPlacement([on(S,N)|P],Services,[on(S,N)|PPlacement]) :-
    \+member(S,Services), cleanPlacement(P,Services,PPlacement).

sumHWDiffs(N, HWDiffs, HWUpdate) :-
    findall(HW, member(diff(_,N,(_,HW,_)), HWDiffs), L),
    sum_list(L, HWUpdate).

assembleHW((_,NewAllocHW), L, L) :- NewAllocHW=:=0.
assembleHW((N, NewAllocHW), L, [(N,NewAllocHW)|L]) :- NewAllocHW>0.

sumBWDiffs(N1,N2,BWDiffs,BWUpdate) :-
    findall(BW, member(diff(_,N1,_,N2,(_,BW)), BWDiffs), L),
    sum_list(L, BWUpdate).
    
assembleBW((_,_,AllocatedBW), L, L) :- AllocatedBW =:= 0.
assembleBW((N1,N2,AllocatedBW), L, [(N1,N2,AllocatedBW)|L]) :- AllocatedBW>0.

assembleDiff(S1, N1, HWDiff, [], [diff(S1,N1,HWDiff)]).
assembleDiff(S1, N1, HWDiff, [diff(S1,N1,OldHWDiff)|HWDiffs], [diff(S1,N1,MinHWDiff)|HWDiffs]) :-
    MinHWDiff is min(HWDiff, OldHWDiff).
assembleDiff(S1, N1, HWDiff, [diff(S2,N2,HWDiff2)|HWDiffs], [diff(S2,N2,HWDiff2)|NewHWDiffs]) :-
    (dif(S1,S2); dif(N1,N2)), assembleDiff(S1, N1, HWDiff, HWDiffs, NewHWDiffs).