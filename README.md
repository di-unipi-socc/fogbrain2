<p><img align="left"  src="http://pages.di.unipi.it/forti/fogbrain/img/logo.png" width="100"> <h1>FogBrain2</h1></p>

_continuous reasoning for managing next-gen distributed applications_

<br></br>

## Background & Prerequisites

FogBrain is written in Prolog. Prolog programs are finite sets of *clauses* of the form:

```prolog
a :- b1, ... , bn.
```

stating that `a` holds when `b1` and ... and `bn` holds, where `n =< 0` and `a`, `b1` ..., `bn` are atomic literals. Clauses with empty condition are also called *facts*. Prolog variables begin with upper-case letters, lists are denoted by square brackets, and negation by `\+`.

Before using **FogBrain** you need to install the latest stable release of [SWI-Prolog](https://www.swi-prolog.org/download/stable).

## QuickStart 

To try **FogBrain**:

1. Download or clone this repository.

2. Open a terminal in the project folder and run `swipl fogbrain.pl`.

3. Inside the running program either run the query
   ```prolog
   :- fogBrain('vrApp.pl', P).
   ``` 
   The output will be a first placement for the application described in `vrApp.pl` onto the infrastructure described in `infra.pl`. 
   E.g.
   ```prolog
   % 18,253 inferences, 0.000 CPU in 0.004 seconds (0% CPU, Infinite Lips)
   P = [on(vrDriver, accesspoint0), on(sceneSelector, cabinetserver0), on(videoStorage, cloud0)]
   ```

4. Open the file `infra.pl` and change some of the links or nodes involved in the placement output at step 3. 
   E.g.
   ```prolog
	node(cloud0, [ubuntu, mySQL, gcc, make], inf, []). --> node(cloud0, [], inf, []).
   ```

5. Repeat step 3. The output will only compute a new placement for suffering services (i.e. mapped onto overloaded nodes, or relying upon saturated end-to-end links for interacting with other services) and require many less inferences with respect to computing the initial placement. E.g.
	```prolog
	2 ?- fogBrain('vrApp.pl',P).
	% 713 inferences, 0.000 CPU in 0.001 seconds (0% CPU, Infinite Lips)
   P = [on(videoStorage, cloud1), on(vrDriver, accesspoint0), on(sceneSelector, cabinetserver0)]
	```
In this example the new placement is computed by saving around 96% of inferences with respect to the first deployment.

