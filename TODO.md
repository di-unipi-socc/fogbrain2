0. Testare che gestiamo tutti i casi di cambiamento dell'infrastruttura e dell'applicazione. 
   Testare che se il reasoning fallisce, FB2.0 ricomincia la ricerca completa. 

1. Generare due versioni:
    - A: dove si calcolano i diff per latenza e TReqs e SWReqs, e si dividono problemi infrastrutturali da problemi dovuti al cambiamento di requisiti,
    - B: dove non si calcolano i diff per latenza e TReqs e SWReqs.

2. Introdurre *iterative deepening search* in A e B.  
    - A+IDSearch
    - B+IDSearch

3. Commentare in stile Prolog.

4. \[Introdurre explainability.\]