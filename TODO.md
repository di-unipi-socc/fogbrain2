0. Capire come (se è necessario) "ripulire" la KB dal descrittore dell'applicazione.

1. Generare due versioni:
    - A: dove si calcolano i diff per latenza e TReqs e SWReqs, e si dividono problemi infrastrutturali da problemi dovuti al cambiamento di requisiti,
    - B: dove non si calcolano i diff per latenza e TReqs e SWReqs.
2. Testare che gestiamo tutti i casi di cambiamento dell'infrastruttura e dell'applicazione. Testare che se il reasoning fallisce, FB2.0 ricomincia la ricerca completa. 
3. Introdurre *iterative deepening search* in A e B.  
    - A+IDSearch
    - B+IDSearch

4. Commentare in stile Prolog.

5. \[Introdurre explainability.\]