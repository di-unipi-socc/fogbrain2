% affinity: se si mette latency tra due servizi a 0 o banda a infinito i due servizi vengono posizionati nello stesso nodo
% cosa fare se service o s2s non sono più dichiarati?
% cosa fare se fallisce reasoningStep per overflow? (per ora non triggera il placement totale) 
reasoningStep(App, Placement, AllocHW, AllocBW, ContextServices, ContextS2Ss, NewPlacement) :-

    application(App, Services),
    toRemove(Placement, Services, ServicesToRemove),
    freeResources(App, ServicesToRemove, Placement, AllocHW, AllocBW, PPlacement, PAllocHW, PAllocBW),
    
    toAdd(PPlacement, Services, ServicesToAdd),

    newAllocHW(PPlacement, PAllocHW, ContextServices, NewAllocHW),%too heavy?
    newAllocBW(PPlacement, PAllocBW, ContextS2Ss, NewAllocBW),%too heavy?
    toMigrate(PPlacement, ServicesToMigrate, NewAllocHW, NewAllocBW),
    freeResources(App, ServicesToMigrate, PPlacement, NewAllocHW, NewAllocBW, FixedPlacement, FixedAllocHW, FixedAllocBW),
    findall(S, (member((S,_,_), ServicesToMigrate)), MigratingServices),
    
    append(MigratingServices, ServicesToAdd, ServicesToPlace),
    replacement(App, ServicesToPlace, FixedPlacement, FixedAllocHW, FixedAllocBW, NewPlacement).

newAllocHW(Placement, AllocHW, ContextServices, NewAllocHW) :-
    findall((N,Diff), (member(on(S,N),Placement), member(service(S, _, HWReqsOld, _),ContextServices), service(S, _, HWReqsNew, _), Diff is HWReqsNew-HWReqsOld, Diff \== 0), Diffs),
    append(Diffs, AllocHW, TmpAlloc), sort(TmpAlloc, SortedAlloc),
    sumAllocHw(SortedAlloc, [], NewAllocHW).

sumAllocHw([], AllocHW, AllocHW).
sumAllocHw([(N,HW)|AllocHW], [], NewAllocHW) :-
    sumAllocHw(AllocHW, [(N,HW)], NewAllocHW).
sumAllocHw([(N,HW1)|AllocHW], [(N,HW2)|TmpAlloc], NewAllocHW) :-
    HW is HW1+HW2, sumAllocHw(AllocHW, [(N,HW)|TmpAlloc], NewAllocHW).
sumAllocHw([(N,HW1)|AllocHW], [(N1,HW2)|TmpAlloc], NewAllocHW) :-
    N \== N1, sumAllocHw(AllocHW, [(N,HW1),(N1,HW2)|TmpAlloc], NewAllocHW).

%prendere bw da contesto (o versione precedente)
newAllocBW(Placement, AllocBW, ContextS2Ss, NewAllocBW) :-
    findall((N1,N2,Diff), (member(s2s(S1, S2, _, BWReqsOld),ContextS2Ss), s2s(S1, S2, _, BWReqsNew), member(on(S1,N1),Placement), member(on(S2,N2),Placement),  Diff is BWReqsNew-BWReqsOld, Diff \== 0), Diffs),
    append(Diffs, AllocBW, TmpAlloc), sort(TmpAlloc, SortedAlloc),
    sumAllocBw(SortedAlloc, [], NewAllocBW).

sumAllocBw([], AllocBW, AllocBW).
sumAllocBw([(N1,N2,BW)|AllocBW], [], NewAllocBW) :-
    sumAllocBw(AllocBW, [(N1,N2,BW)], NewAllocBW).
sumAllocBw([(N1,N2,BW1)|AllocBW], [(N1,N2,BW2)|TmpAlloc], NewAllocBW) :-
    BW is BW1+BW2, sumAllocBw(AllocBW, [(N1,N2,BW)|TmpAlloc], NewAllocBW).
sumAllocBw([(N1,N2,BW1)|AllocBW], [(N3,N4,BW2)|TmpAlloc], NewAllocBW) :-
    \+ (N1 == N3, N2 == N4), sumAllocBw(AllocBW, [(N1,N2,BW1),(N3,N4,BW2)|TmpAlloc], NewAllocBW).

%prendere hw da contesto (o versione precedente)
toRemove(Placement, Services, ServicesToRemove) :-
    findall((S,N,HWReqs), ( member( on(S,N),Placement ), (\+( member(S,Services) )), service(S, _, HWReqs, _), write('Removing Service '),write(S), write(' on Node '), writeln(N)), ServicesToRemove). %cosa acacde se il predicato service(S,...) non esiste più? come recupero HwReqs?

toAdd(Placement, Services, ServicesToAdd) :-
    findall(S, ( member(S,Services), \+( member(on(S,_),Placement) ), service(S, _, _, _), write('Adding Service '),writeln(S) ), ServicesToAdd).

toMigrate(Placement, ServicesToMigrate, AllocHW, AllocBW) :-
    findall((S,N,HWReqs), (onSufferingNode(S,N,HWReqs,Placement,AllocHW), write('Migrating Service '),write(S), write(' because on suffering Node '), writeln(N)), ServiceDescr1),
    findall(((S1,N1,HWReqs1),(S2,N2,HWReqs2)), (onSufferingLink((S1,N1,HWReqs1),(S2,N2,HWReqs2),Placement,AllocBW), write('Migrating Services '), write((S1,S2)), write(' because on suffering Link '), writeln((N1,N2)) ), ServiceDescr2),
    merge(ServiceDescr2, ServiceDescr1, ServicesToMigrate).

onSufferingNode(S, N, HWReqs, Placement, AllocHW) :-  
    member(on(S,N), Placement),
    service(S, SWReqs, HWReqs, TReqs),
    nodeProblem(N, SWReqs, TReqs, AllocHW).

%spostare solo servizi variati?
nodeProblem(N, SWReqs, TReqs, AllocHW) :-
    node(N, SWCaps, HWCaps, TCaps),
    hwTh(T), 
    member((N,CurrentHW),AllocHW),
    \+ (HWCaps > T,  HWCaps >= CurrentHW + T, thingReqsOK(TReqs,TCaps), swReqsOK(SWReqs,SWCaps)).
nodeProblem(N, _, _, _) :- 
    \+ node(N, _, _, _).

onSufferingLink((S1,N1,HWReqs1),(S2,N2,HWReqs2),Placement,AllocBW) :-
    member(on(S1,N1), Placement), member(on(S2,N2), Placement), N1 \== N2,
    s2s(S1, S2, ReqLat, _),
    communicationProblem(N1, N2, ReqLat, AllocBW),
    service(S1, _, HWReqs1, _),
    service(S2, _, HWReqs2, _).

communicationProblem(N1, N2, ReqLat, AllocBW) :- 
    link(N1, N2, FeatLat, FeatBW), 
    bwTh(T),
    member((N1,N2,CurrentBW),AllocBW),
    ((FeatBW =< CurrentBW + T);
    (FeatLat > ReqLat; FeatBW < T)).
communicationProblem(N1,N2,_,_) :- 
    \+ link(N1, N2, _, _).

merge([], L, L).
merge([(D1,D2)|Ds], L, NewL) :- merge2(D1, L, L1), merge2(D2, L1, L2), merge(Ds, L2, NewL).
merge2(D, [], [D]).
merge2(D, [D|L], [D|L]).
merge2(D1, [D2|L], [D2|NewL]) :- D1 \== D2, merge2(D1, L, NewL).

% IN fogbrain.pl: itTh(T). % numero massimo di servizi nella frontiera (altrimenti calcola il piazzamento totale)
replacement(_, [], Placement, _, _, Placement).
replacement(A, Frontier, Placement, AllocHW, AllocBW, NewPlacement) :-
    Frontier \== [], deploy(A, Frontier, Placement, AllocHW, AllocBW, NewPlacement). % prova a deployare

deploy(A, Frontier, Placement, AllocHW, AllocBW, NewPlacement) :-
    write('Trying to place '), write(Frontier), write(' given '), writeln(Placement),
    placement(Frontier, AllocHW, NewAllocHW, AllocBW, NewAllocBW, Placement, NewPlacement),

    application(A, Services),
    findall(service(S, SW, HW, TH), (member(S,Services), service(S, SW, HW, TH)), ContextServices),
	findall(s2s(S, S2, LA, BW), (member(S,Services), s2s(S, S2, LA, BW)), ContextS2Ss),
	
    retract(deployment(A, _, _, _, _, _)),
    assert(deployment(A, NewPlacement, NewAllocHW, NewAllocBW, ContextServices, ContextS2Ss)).

deploy(A, Frontier, Placement, AllocHW, AllocBW, NewPlacement) :-
    \+(placement(Frontier, AllocHW, _, AllocBW, _, Placement, _)), % da ottimizzare
    writeln('Failed, starting new iteration...'),
    findall(Neighbor, (member(S,Frontier), (s2s(S,Neighbor,_,_); s2s(Neighbor,S,_,_))), Neighbors), %trova tutti i vicini
    append(Neighbors,Frontier,NewNeighbors), % fondi la lista con quella iniziale
    sort(NewNeighbors,NewServices), %rimuovi i duplicati
    length(Frontier, ServicesLen), 
    length(NewServices, NeighborsLen),
    itTh(T), 
    NeighborsLen =< T, % verifica che il numero massimo di servizi nella frontiera sia sotto la soglia massima (altrimenti fai il piazzamento totale) (trasformare in numero di iterazioni?)
    ServicesLen \== NeighborsLen, % verifica che le liste siano diverse (altrimenti loop)
    findall((S,N,HWReqs), (member(S,NewServices), member(on(S,N), Placement), service(S, _, HWReqs, _)), ServicesToFree),
    freeResources(A, ServicesToFree, Placement, AllocHW, AllocBW, PPlacement, PAllocHW, PAllocBW),
    replacement(A, NewServices, PPlacement, PAllocHW, PAllocBW, NewPlacement). % prova a piazzarli

partialPlacement([],_,[]).
partialPlacement([on(S,_)|P],Services,PPlacement) :-
    member(S,Services), partialPlacement(P,Services,PPlacement).
partialPlacement([on(S,N)|P],Services,[on(S,N)|PPlacement]) :-
    \+member(S,Services), partialPlacement(P,Services,PPlacement).

freeResources(_, [], Placement, AllocHW, AllocBW, Placement, AllocHW, AllocBW).
freeResources(_, [S1|ServicesToFree], Placement, AllocHW, AllocBW, PPlacement, PAllocHW, PAllocBW) :-
    findall(S, member((S,_,_), [S1|ServicesToFree]), Services),
    partialPlacement(Placement, Services, PPlacement),
    freeHWAllocation(AllocHW, PAllocHW, [S1|ServicesToFree]),
    freeBWAllocation(AllocBW, PAllocBW, [S1|ServicesToFree], Placement). 
 
freeHWAllocation([], [], _).
freeHWAllocation([(N,AllocHW)|L], NewL, ServicesToFree) :-
    sumNodeHWToFree(N, ServicesToFree, HWToFree),
    NewAllocHW is AllocHW - HWToFree, 
    freeHWAllocation(L, TempL, ServicesToFree),
    assemble((N,NewAllocHW), TempL, NewL).

sumNodeHWToFree(_, [], 0).
sumNodeHWToFree(N, [(_,N,H)|STMs], Tot) :- sumNodeHWToFree(N, STMs, HH), Tot is H+HH.
sumNodeHWToFree(N, [(_,N1,_)|STMs], H) :- N \== N1, sumNodeHWToFree(N, STMs, H).
 
assemble((_,NewAllocHW), L, L) :- NewAllocHW=:=0.
assemble((N, NewAllocHW), L, [(N,NewAllocHW)|L]) :- NewAllocHW>0.
 
freeBWAllocation([],[],_,_).
freeBWAllocation([(N1,N2,AllocBW)|L], NewL, ServicesToFree, Placement) :-
   findall(BW, toFree(N1,N2,BW,ServicesToFree,Placement), BWs),
   sumLinkBWToFree(BWs,V), NewAllocBW is AllocBW-V,
   freeBWAllocation(L, TempL, ServicesToFree, Placement),
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
