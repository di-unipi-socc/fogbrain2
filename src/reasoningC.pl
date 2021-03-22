reasoningStep(AppId, Placement, Alloc, Context, NewPlacement) :-
    appDiff(AppId, Placement, Context, ToAdd, ToRemove, Updates, S2SToUpdate),
    writeln(qui),writeln(ToAdd), writeln(ToRemove), writeln(Updates).
    %cleanDeployment(ToRemove, ToUpdate, S2SToUpdate, Placement, PPlacement, Alloc, PAlloc),
    %replacement(AppId, ToAdd, PPlacement, PAlloc, NewPlacement).

appDiff(AppId, Placement, Context, ToAdd, ToRemove, Updates, S2SToUpdate) :-
    Context=(CtxServices,CtxS2S),
    serviceDiffs(AppId, Placement, CtxServices, ToAdd1, ToRemove1, Updates1),
    s2sDiffs(Placement, CtxServices, CtxS2S, ToAdd2, ToRemove1, ToRemove2, Updates1, Updates, S2SToUpdate), 
    union(ToAdd1,ToAdd2,ToAdd), union(ToRemove1,ToRemove2,ToRemove).

s2sDiffs(Placement, CtxServices, CtxS2S, SToAdd, ToRemove1, SToRemove, Updates, NewUpdates, S2SToUpdate):-
    findall((S1, S2, Lat, BW), (s2s(S1, S2, Lat, BW)), S2Ss),
    changedS2S(S2Ss, Placement, CtxServices, CtxS2S, ToRemove1, SToRemove, SToAdd, Updates, NewUpdates, S2SToUpdate).

changedS2S([], Placement, _, CtxS2S, SToRemove, [], [], Updates, Updates, S2SToRemove) :-
    removedS2S(CtxS2S,Placement,SToRemove,[],S2SToRemove).
%%% FROM HERE:
changedS2S([(S1, S2, ReqLat, ReqBW)|S2Ss], Placement, CtxServices, CtxS2S, ToRemove1, SToRemove, SToAdd, Updates, NewUpdates, S2SToUpdate) :-
    changedS2S(S2Ss, Placement, CtxServices, CtxS2S, ToRemove1, TmpSToRemove, TmpSToAdd, Updates, TmpUpdates, TmpS2SToUpdate),
    s2sDiff(S1, S2, ReqLat, ReqBW, Placement, CtxS2S, Diff),
    sortS2S(Diff, CtxServices, CtxS2S, TmpSToRemove, TmpSToAdd, TmpS2SToUpdate, SToRemove, SToAdd, TmpUpdates, NewUpdates, S2SToUpdate).

% removedS2S(CtxS2S,Placement,ToRemove1,[],S2SToRemove).
removedS2S([], _, _, S2SUpdates, S2SUpdates).
removedS2S([s2s(S1, S2, _, ReqBW)|CtxS2Ss], Placement, SToRemove, S2SUpdates, NewS2SUpdates) :-
    ( ( \+ s2s(S1, S2, _, _) ) ; ( member(S1,SToRemove) ; member(S2,SToRemove) ) ),
    member(on(S1,N1),Placement), member(on(S2,N2),Placement), dif(N1,N2),
    updateUpdates(S2SUpdates,N1,N2,-ReqBW,TmpS2SUpdates),
    removedS2S(CtxS2Ss, Placement, SToRemove, TmpS2SUpdates, NewS2SUpdates).
removedS2S([s2s(S1, S2, _, _)|CtxS2Ss], Placement, SToRemove, S2SUpdates, NewS2SUpdates) :-
    s2s(S1, S2, _, _),
    removedS2S(CtxS2Ss, Placement, SToRemove, S2SUpdates, NewS2SUpdates).

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

sortS2S(D, _, _, SToRemove, SToAdd, S2SToUpdate, SToRemove, SToAdd, S2SToUpdate) :-
    D=pass; ( D = diff(S1,N1,S2,N2,_), member(diff(S1,N1,S2,N2,_), S2SToUpdate) ). % it's a pass or it's already to be removed fully
sortS2S(diff(S1,N1,S2,N2,Diff), _, _, SToRemove, SToAdd, S2SToUpdate, SToRemove, SToAdd, [diff(S1,N1,S2,N2,Diff)|S2SToUpdate]) :-
    \+ member(diff(S1,N1,S2,N2,_), S2SToUpdate), toUpdate(N1,N2,Diff).
sortS2S(diff(S1,N1,S2,N2,Diff), CtxServices, _, SToRemove, SToAdd, S2SToUpdate, NewSToRemove, NewSToAdd, [diff(S1,N1,S2,N2,Diff)|S2SToUpdate]) :-
    \+ member(diff(S1,N1,S2,N2,_), S2SToUpdate), toReplace(N1,N2,Diff),
    serviceDiff(S1, [on(S1,N1)], CtxServices, Diff1), serviceDiff(S2, [on(S2,N2)], CtxServices, Diff2),
    append(Diff1,SToRemove,Tmp1), union(Diff2,Tmp1,NewSToRemove),
    append(S1,SToAdd,Tmp2), union(S2,Tmp2,NewSToAdd).
sortS2S(D, _, _, SToRemove, SToAdd, S2SToUpdate, SToRemove, SToAdd, S2SToUpdate) :-
    D = diff(_,_,_,_,(_,BWDiff)), BWDiff =:= 0. %LatDiff =:= 0

toUpdate(N1,N2,(ReqLat,BWDiff)):-
    BWDiff =\= 0,
    link(N1,N2,FeatLat,FeatBW),
    FeatLat =< ReqLat, bwTh(T), FeatBW >= T + BWDiff.

toReplace(N1,N2,(ReqLat,BWDiff)):- 
    link(N1,N2,FeatLat,FeatBW),
    bwTh(T), \+ (FeatLat =< ReqLat, FeatBW >= T + BWDiff).
toReplace(N1,N2,_):-
    \+ link(N1,N2,_,_).

cleanDeployment(ToRemove, ToUpdate, S2SToUpdate, Placement, PPlacement, Alloc, PAlloc) :-
    getServiceIDs(ToRemove, ToRemoveSIDs), union(ToUpdate, ToRemove, ToClean),
    cleanResourceAllocation(ToClean, S2SToUpdate, Alloc, PAlloc),
    cleanPlacement(Placement, ToRemoveSIDs, PPlacement).

replacement(A, [], Placement, Alloc, Placement) :-
    retract(deployment(A, _, _, _)), deploy(A, Placement, Alloc).
replacement(A, ServicesToPlace, Placement, Alloc, NewPlacement) :-
    dif(ServicesToPlace,[]), retract(deployment(A, _, _, _)),
    placement(ServicesToPlace, Alloc, NewAlloc, Placement, NewPlacement),
    deploy(A, NewPlacement, NewAlloc).

serviceDiffs(AppId,Placement, CtxServices, ToAdd, ToRemove, Updates) :-
    application(AppId, Services),
    changedServices(Services, Placement, CtxServices, ToAdd, ToRemove, Updates).

changedServices([], Placement, CtxServices, [], ToRemove, Updates) :-
    removedServices(CtxServices,Placement,ToRemove,[],Updates).
changedServices([S|Services], Placement, CtxServices, NewToAdd, NewToRemove, NewUpdates) :-
    changedServices(Services, Placement, CtxServices, TmpToAdd, TmpToRemove, TmpUpdates),
    serviceDiff(S, Placement, CtxServices, Diff),
    sortService(Diff, CtxServices, TmpToAdd, TmpToRemove, TmpUpdates, NewToAdd, NewToRemove, NewUpdates).

removedServices([], _, [], Updates, Updates).
removedServices([service(S, _, HWReqs, _)|CtxServices], Placement, [S|Rest], Updates, NewUpdates) :- %diff(S,N,(SWReqs, -HWReqs, TReqs))
    \+ service(S, _, _, _), member(on(S,N), Placement),
    updateUpdates(Updates, N, -HWReqs, TmpUpdates),
    removedServices(CtxServices, Placement, Rest, TmpUpdates, NewUpdates).
removedServices([service(S, _, _, _)|CtxServices], Placement, Rest, Updates, NewUpdates) :-
    service(S, _, _, _),
    removedServices(CtxServices, Placement, Rest, Updates, NewUpdates).

serviceDiff(S, Placement, CtxServices, diff(S,N,(SWReqs,HWDiff,TReqs))) :-
    member(service(S, _, HWReqsOld, _),CtxServices),
    service(S, SWReqs, HWReqs, TReqs),
    HWDiff is HWReqs - HWReqsOld,
    (member(on(S,N),Placement); N=none).
serviceDiff(S, _, CtxServices, diff(S,none,(SWReqs,HWReqs,TReqs))) :-
    \+ member(service(S, _, _, _),CtxServices),
    service(S, SWReqs, HWReqs, TReqs).

sortService(diff(S,none,_), _, ToAdd, ToRemove, Updates, [S|ToAdd], ToRemove, Updates).
sortService(diff(S,N,D), CtxServices, ToAdd, ToRemove, Updates, [S|ToAdd], [S|ToRemove], NewUpdates) :- 
    dif(N,none), serviceToMigrate(N,D,Updates), 
    member(service(S, _, HWReqsOld, _),CtxServices), 
    updateUpdates(Updates, N, -HWReqsOld, NewUpdates). %
sortService(diff(_,N,D), _, ToAdd, ToRemove, Updates, ToAdd, ToRemove, NewUpdates) :- 
    dif(N,none), serviceToUpdate(N,D,Updates), 
    D=(_,H,_), updateUpdates(Updates, N, H, NewUpdates).
sortService(diff(_,N,(_,0,_)), _, ToAdd, ToRemove, Updates, ToAdd, ToRemove, Updates) :- 
    dif(N,none).

serviceToMigrate(N,(SWReqs,HWDiff,TReqs),Updates) :-
    node(N, SWCaps, HWCaps, TCaps), 
    ( member((N,HWUpdate), Updates) ; HWUpdate = 0 ),
    hwTh(T), \+ (swReqsOK(SWReqs, SWCaps), HWCaps > HWUpdate + HWDiff + T, thingReqsOK(TReqs, TCaps)).
serviceToMigrate(N,_,_) :-
    \+ node(N, _, _, _).

serviceToUpdate(N,(SWReqs,HWDiff,TReqs), Updates) :-
    HWDiff =\= 0, ( member((N,HWUpdate), Updates) ; HWUpdate = 0 ),
    node(N, SWCaps, HWCaps, TCaps),
    swReqsOK(SWReqs, SWCaps), 
    hwTh(T), HWCaps > HWUpdate + HWDiff + T, 
    thingReqsOK(TReqs, TCaps).

updateUpdates([], N, H, [(N,H)]).
updateUpdates([(N,OldH)|Ns], N, H, [(N,NewH)|Ns]) :-
    NewH is OldH + H.
updateUpdates([(M,OldH)|Ns], N, H, [(M,OldH)|NewNs]) :-
    dif(M,N), updateUpdates(Ns, N, H, NewNs).

updateUpdates([], N1, N2, BW, [(N1,N2,BW)]).
updateUpdates([(N1,N2,OldBW)|Ns], N1, N2, BW, [(N1,N2,NewBW)|Ns]) :-
    NewBW is OldBW + BW.
updateUpdates([(N3,N4,OldH)|Ns], N1, N2, BW, [(N3,N4,OldH)|NewNs]) :-
    dif(N1,N3), dif(N2,N4), updateUpdates(Ns, N1, N2, BW, NewNs).



cleanResourceAllocation(ToClean, S2S, (AllocHW, AllocBW), (NewAllocHW, NewAllocBW)) :-
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

cleanPlacement(P,[],P).
cleanPlacement([],_,[]).
cleanPlacement([on(S,_)|P],Services,PPlacement) :-
    member(S,Services), cleanPlacement(P,Services,PPlacement).
cleanPlacement([on(S,N)|P],Services,[on(S,N)|PPlacement]) :-
    \+member(S,Services), cleanPlacement(P,Services,PPlacement).

getServiceIDs(List, Services) :- findall(S, (member(diff(S,_,_),List)), Services).

sumNodeHWDiff(_, [], 0).
sumNodeHWDiff(N, [diff(_,N,(_,HWDiff,_))|STMs], Tot) :- sumNodeHWDiff(N, STMs, HH), Tot is HWDiff+HH.
sumNodeHWDiff(N, [diff(_,N1,_)|STMs], H) :- dif(N,N1), sumNodeHWDiff(N, STMs, H).
 
assembleHW((_,NewAllocHW), L, L) :- NewAllocHW=:=0.
assembleHW((N, NewAllocHW), L, [(N,NewAllocHW)|L]) :- NewAllocHW>0.
 
sumLinkBWDiff(_, _, [], 0).
sumLinkBWDiff(N1, N2, [diff(_,N1,_,N2,(_,BWDiff))|STMs], Tot) :- sumLinkBWDiff(N1, N2, STMs, BB), Tot is BWDiff+BB.
sumLinkBWDiff(N1, N2, [diff(_,N3,_,N4,_)|STMs], B) :- (dif(N1,N3);dif(N2,N4)), sumLinkBWDiff(N1, N2, STMs, B).

assembleBW((_,_,AllocatedBW), L, L) :- AllocatedBW =:= 0.
assembleBW((N1,N2,AllocatedBW), L, [(N1,N2,AllocatedBW)|L]) :- AllocatedBW>0.

listDiff(_,[],[]).
listDiff(L1,[L|Ls],Add) :- member(L,L1), listDiff(L1,Ls,Add).
listDiff(L1,[L|Ls],[L|Add]) :- \+ member(L,L1), listDiff(L1,Ls,Add).