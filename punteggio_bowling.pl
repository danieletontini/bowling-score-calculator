/* Programma Prolog per calcolare il punteggio di una partita di
   bowling. */

/* Il risultato di uno dei dieci turni di una partita di bowling e'
   rappresentato mediante:
   - il termine strike(P), che rappresenta un turno chiuso abbattendo
     tutti i birilli con il primo lancio;
   - il termine spare(P), che rappresenta un turno chiuso abbattendo
     tutti i birilli con i due lanci del turno;
   - il termine aperto(P), che rappresenta un turno i cui due lanci non
     abbattono tutti i birilli,
   dove l'argomento P e' il punteggio del turno, gia' comprensivo degli
   eventuali bonus. */

/* Il predicato main acquisisce la sequenza dei lanci di una partita di
   bowling e stampa il prospetto dei dieci turni, con il punteggio e il
   totale parziale di ciascuno, seguito dal punteggio totale della
   partita. */
main :- acquisisci_partita(Partita),
        nl,
        write('>> Punteggio dei singoli turni:'), nl,
        totali(0, Partita, Cumulativi),
        stampa_turni(1, Partita, Cumulativi),
        write('>> Punteggio totale della partita:'), nl,
        punteggio_totale(Partita, Totale),
        write(Totale), nl.

/* Il predicato acquisisci_partita acquisisce la sequenza dei lanci di
   una partita, delegando a controlla_partita la verifica della
   validita' dell'input:
   - il suo unico argomento e' la lista dei dieci turni calcolati. */
acquisisci_partita(Partita) :-
    write('Digita i lanci separati da virgole e racchiusi tra parentesi'),
    write(' quadre, terminando con un punto:'), nl,
    read(Lanci),
    controlla_partita(Lanci, Partita).

/* Il predicato controlla_partita restituisce i dieci turni calcolati se
   la sequenza acquisita descrive una partita valida, altrimenti segnala
   l'errore e richiede nuovamente la sequenza dei lanci:
   - il primo argomento e' la sequenza dei lanci acquisita;
   - il secondo argomento e' la lista dei dieci turni calcolati. */
controlla_partita(Lanci, Partita) :- turni(1, Lanci, Partita), !.
controlla_partita(_, Partita) :- write('>> Partita non valida.'), nl,
                                 acquisisci_partita(Partita).

/* Il predicato turni consuma la sequenza dei lanci e costruisce la
   lista dei turni della partita, fallendo se la sequenza non descrive
   una partita valida:
   - il primo argomento e' il numero del turno da calcolare;
   - il secondo argomento e' la sequenza dei lanci non ancora consumati;
   - il terzo argomento e' la lista dei turni calcolati.
   Caso base: il turno da calcolare e' il decimo, che segue regole
   proprie ed e' delegato a turno_finale.
   Caso generale con strike: il primo lancio abbatte tutti i birilli, il
   turno si chiude consumando un solo lancio e il suo punteggio e' dieci
   piu' la somma dei due lanci successivi, che vengono letti nella
   sequenza non ancora consumata senza essere consumati.
   Caso generale con spare: i due lanci del turno abbattono tutti i
   birilli e il punteggio e' dieci piu' il lancio successivo.
   Caso generale con turno aperto: i due lanci del turno non abbattono
   tutti i birilli e il punteggio e' la loro somma.
   Le condizioni delle tre clausole generali sono mutuamente esclusive,
   percio' non e' necessario alcun cut per selezionare il caso. */
turni(10, Lanci, [Turno]) :- turno_finale(Lanci, Turno).
turni(N, [10 | Resto], [strike(P) | Altri]) :-
    N < 10,
    somma_primi(2, Resto, S), P is 10 + S,
    N1 is N + 1, turni(N1, Resto, Altri).
turni(N, [A, B | Resto], [spare(P) | Altri]) :-
    N < 10, coppia_valida(A, B), A < 10, A + B =:= 10,
    somma_primi(1, Resto, S), P is 10 + S,
    N1 is N + 1, turni(N1, Resto, Altri).
turni(N, [A, B | Resto], [aperto(P) | Altri]) :-
    N < 10, coppia_valida(A, B), A + B < 10, P is A + B,
    N1 is N + 1, turni(N1, Resto, Altri).

/* Il predicato turno_finale calcola il decimo turno, nel quale uno
   strike o uno spare danno diritto ai lanci di bonus e il punteggio e'
   la somma dei birilli abbattuti, senza ulteriori bonus:
   - il primo argomento e' la sequenza dei lanci non ancora consumati,
     che deve esaurirsi con il decimo turno;
   - il secondo argomento e' il turno calcolato.
   Caso con strike: il primo lancio abbatte tutti i birilli e seguono
   due lanci di bonus.
   Caso con spare: i primi due lanci abbattono tutti i birilli e segue
   un solo lancio di bonus.
   Caso con turno aperto: i due lanci non abbattono tutti i birilli e
   non danno diritto ad alcun bonus. */
turno_finale([10, B, C], strike(P)) :-
    bonus_validi(B, C), P is 10 + B + C.
turno_finale([A, B, C], spare(P)) :-
    coppia_valida(A, B), A < 10, A + B =:= 10, lancio_valido(C),
    P is 10 + C.
turno_finale([A, B], aperto(P)) :-
    coppia_valida(A, B), A + B < 10, P is A + B.

/* Il predicato somma_primi calcola la somma dei primi lanci di una
   sequenza ed e' lo strumento con cui i turni chiusi con strike o con
   spare leggono in avanti i lanci successivi:
   - il primo argomento e' il numero di lanci da sommare;
   - il secondo argomento e' la sequenza dei lanci;
   - il terzo argomento e' la somma calcolata.
   Caso base: non resta alcun lancio da sommare.
   Caso degenere: la sequenza e' esaurita prima del previsto, situazione
   che si presenta soltanto in una partita incompleta e che viene poi
   respinta dal calcolo del decimo turno.
   Caso generale: il primo lancio contribuisce alla somma dei
   rimanenti. */
somma_primi(0, _, 0).
somma_primi(N, [], 0) :- N > 0.
somma_primi(N, [A | Resto], S) :-
    N > 0, N1 is N - 1, somma_primi(N1, Resto, S1), S is A + S1.

/* Il predicato bonus_validi verifica che i due lanci di bonus del
   decimo turno siano ammissibili:
   - il primo argomento e' il primo lancio di bonus;
   - il secondo argomento e' il secondo lancio di bonus.
   Caso base: il primo bonus abbatte tutti i birilli, che vengono percio'
   ricomposti, e il secondo bonus e' libero di assumere qualsiasi valore.
   Caso generale: i due bonus insistono sulla stessa disposizione di
   birilli e devono percio' formare una coppia ammissibile. */
bonus_validi(10, C) :- lancio_valido(C).
bonus_validi(B, C) :- coppia_valida(B, C), B < 10.

/* Il predicato coppia_valida verifica che due lanci effettuati sulla
   stessa disposizione di birilli siano ammissibili, ovvero che non ne
   abbattano complessivamente piu' di dieci:
   - il primo argomento e' il primo dei due lanci;
   - il secondo argomento e' il secondo dei due lanci. */
coppia_valida(A, B) :- lancio_valido(A), lancio_valido(B), A + B =< 10.

/* Il predicato lancio_valido verifica che un lancio abbatta un numero
   di birilli compreso tra zero e dieci:
   - il suo unico argomento e' il lancio da verificare. */
lancio_valido(A) :- integer(A), A >= 0, A =< 10.

/* Il predicato totali calcola la lista dei punteggi cumulativi, ovvero
   il totale della partita al termine di ciascun turno:
   - il primo argomento e' il totale accumulato nei turni precedenti;
   - il secondo argomento e' la lista dei turni ancora da considerare;
   - il terzo argomento e' la lista dei punteggi cumulativi. */
totali(_, [], []).
totali(Acc, [Turno | Altri], [Totale | Cumulativi]) :-
    punteggio(Turno, P),
    Totale is Acc + P,
    totali(Totale, Altri, Cumulativi).

/* Il predicato stampa_turni stampa il prospetto dei turni, riportando
   per ciascuno di essi il numero, il punteggio, il totale parziale
   della partita e il modo di chiusura del turno:
   - il primo argomento e' il numero del turno da stampare;
   - il secondo argomento e' la lista dei turni ancora da stampare;
   - il terzo argomento e' la lista dei corrispondenti punteggi
     cumulativi. */
stampa_turni(_, [], []).
stampa_turni(N, [Turno | Altri], [C | Restanti]) :-
    write('Turno '), allinea(2, N),
    punteggio(Turno, P),
    write(':  punteggio '), allinea(2, P),
    write('   totale parziale '), allinea(3, C),
    nome_turno(Turno, Nome),
    write('   ('), write(Nome), write(')'), nl,
    N1 is N + 1,
    stampa_turni(N1, Altri, Restanti).

/* Il predicato allinea stampa un numero allineato a destra entro una
   larghezza prefissata, anteponendo gli spazi necessari, in modo che le
   colonne del prospetto risultino incolonnate:
   - il primo argomento e' la larghezza desiderata;
   - il secondo argomento e' il numero da stampare. */
allinea(Larghezza, Numero) :- cifre(Numero, C),
                              Spazi is Larghezza - C,
                              stampa_spazi(Spazi),
                              write(Numero).

/* Il predicato cifre calcola il numero di cifre decimali di un numero
   naturale:
   - il primo argomento e' il numero di cui contare le cifre;
   - il secondo argomento e' il numero di cifre calcolato. */
cifre(Numero, 1) :- Numero < 10.
cifre(Numero, C) :- Numero >= 10,
                    Numero1 is Numero // 10,
                    cifre(Numero1, C1),
                    C is C1 + 1.

/* Il predicato stampa_spazi stampa un numero prefissato di spazi:
   - il suo unico argomento e' il numero di spazi da stampare. */
stampa_spazi(N) :- N =< 0.
stampa_spazi(N) :- N > 0, write(' '), N1 is N - 1, stampa_spazi(N1).

/* Il predicato nome_turno restituisce la descrizione testuale del modo
   di chiusura di un turno:
   - il primo argomento e' il turno da descrivere;
   - il secondo argomento e' la descrizione testuale. */
nome_turno(strike(_), 'strike').
nome_turno(spare(_), 'spare').
nome_turno(aperto(_), 'turno aperto').

/* Il predicato punteggio_totale calcola il punteggio complessivo della
   partita sommando i punteggi dei singoli turni:
   - il primo argomento e' la lista dei turni della partita;
   - il secondo argomento e' il punteggio totale calcolato. */
punteggio_totale([], 0).
punteggio_totale([Turno | Altri], Totale) :-
    punteggio(Turno, P),
    punteggio_totale(Altri, S),
    Totale is P + S.

/* Il predicato punteggio restituisce il punteggio di un turno,
   indipendentemente dal modo di chiusura del turno:
   - il primo argomento e' il turno di cui calcolare il punteggio;
   - il secondo argomento e' il punteggio del turno. */
punteggio(strike(P), P).
punteggio(spare(P), P).
punteggio(aperto(P), P).