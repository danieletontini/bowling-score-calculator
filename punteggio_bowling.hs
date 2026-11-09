{- Programma Haskell per calcolare il punteggio di una partita di
   bowling. -}

import Text.Read -- necessario per usare readMaybe, che analizza l'input
                 -- restituendo Nothing anziche' terminare in caso di errore

{- Il tipo di dato Turno rappresenta il risultato di uno dei dieci turni
   di una partita di bowling:
   - il costruttore Strike rappresenta un turno chiuso abbattendo tutti
     i birilli con il primo lancio;
   - il costruttore Spare rappresenta un turno chiuso abbattendo tutti i
     birilli con i due lanci del turno;
   - il costruttore Aperto rappresenta un turno i cui due lanci non
     abbattono tutti i birilli,
   dove l'unico argomento di ciascun costruttore e' il punteggio del
   turno, gia' comprensivo degli eventuali bonus. -}
data Turno = Strike Int | Spare Int | Aperto Int

{- L'azione di input/output main acquisisce la sequenza dei lanci di una
   partita di bowling e stampa il prospetto dei dieci turni, con il
   punteggio e il totale parziale di ciascuno, seguito dal punteggio
   totale della partita. -}
main :: IO ()
main = do partita <- acquisisci_partita
          putStrLn ""
          putStrLn ">> Punteggio dei singoli turni:"
          stampa_righe (righe 1 partita (totali 0 partita))
          putStrLn ">> Punteggio totale della partita:"
          putStrLn $ show (punteggio_totale partita)

{- L'azione di input/output acquisisci_partita acquisisce la sequenza
   dei lanci di una partita, delegando ad analizza_partita il calcolo
   dei dieci turni e a controlla_partita la verifica dell'esito
   dell'analisi dell'input. -}
acquisisci_partita :: IO [Turno]
acquisisci_partita = do putStr "Digita i lanci separati da virgole e"
                        putStrLn " racchiusi tra parentesi quadre:"
                        lanci' <- getLine
                        controlla_partita
                          (analizza_partita (readMaybe lanci'))

{- L'azione parametrica di input/output controlla_partita restituisce i
   dieci turni calcolati se l'analisi dell'input e' riuscita, altrimenti
   segnala l'errore e richiede nuovamente la sequenza dei lanci:
   - il suo unico argomento e' l'esito dell'analisi dell'input. -}
controlla_partita :: Maybe [Turno] -> IO [Turno]
controlla_partita (Just partita) = return partita
controlla_partita Nothing        = do putStrLn ">> Partita non valida."
                                      acquisisci_partita

{- L'azione parametrica di input/output stampa_righe stampa una alla
   volta le righe del prospetto dei turni:
   - il suo unico argomento e' la lista delle righe da stampare. -}
stampa_righe :: [String] -> IO ()
stampa_righe []              = return ()
stampa_righe (riga' : righe') = do putStrLn riga'
                                   stampa_righe righe'

{- La funzione analizza_partita calcola i dieci turni della partita a
   partire dall'esito dell'analisi dell'input, restituendo Nothing se
   l'input non e' una lista di numeri interi oppure se la sequenza dei
   lanci non descrive una partita valida:
   - il suo unico argomento e' l'esito dell'analisi dell'input. -}
analizza_partita :: Maybe [Int] -> Maybe [Turno]
analizza_partita Nothing      = Nothing
analizza_partita (Just lanci) = turni 1 lanci

{- La funzione turni consuma la sequenza dei lanci e costruisce la lista
   dei turni della partita, restituendo Nothing se la sequenza non
   descrive una partita valida:
   - il primo argomento e' il numero del turno da calcolare;
   - il secondo argomento e' la sequenza dei lanci non ancora consumati.
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
   Caso degenere: la sequenza dei lanci e' esaurita prima del decimo
   turno oppure i due lanci del turno non sono ammissibili. -}
turni :: Int -> [Int] -> Maybe [Turno]
turni 10 lanci       = turno_finale lanci
turni n (10 : resto) = aggiungi (Strike (10 + somma_primi 2 resto))
                                (turni (n + 1) resto)
turni n (a : b : resto)
  | not (coppia_valida a b) = Nothing
  | a + b == 10             = aggiungi (Spare (10 + somma_primi 1 resto))
                                       (turni (n + 1) resto)
  | otherwise               = aggiungi (Aperto (a + b))
                                       (turni (n + 1) resto)
turni _ _            = Nothing

{- La funzione turno_finale calcola il decimo turno, nel quale uno
   strike o uno spare danno diritto ai lanci di bonus e il punteggio e'
   la somma dei birilli abbattuti, senza ulteriori bonus:
   - il suo unico argomento e' la sequenza dei lanci non ancora
     consumati, che deve esaurirsi con il decimo turno.
   Caso con strike: il primo lancio abbatte tutti i birilli e seguono
   due lanci di bonus.
   Caso con spare: i primi due lanci abbattono tutti i birilli e segue
   un solo lancio di bonus.
   Caso con turno aperto: i due lanci non abbattono tutti i birilli e
   non danno diritto ad alcun bonus.
   Caso degenere: il numero dei lanci residui non e' coerente con
   l'esito del decimo turno. -}
turno_finale :: [Int] -> Maybe [Turno]
turno_finale [10, b, c]
  | bonus_validi b c                = Just [Strike (10 + b + c)]
turno_finale [a, b, c]
  | coppia_valida a b && a < 10 &&
    a + b == 10 && lancio_valido c  = Just [Spare (10 + c)]
turno_finale [a, b]
  | coppia_valida a b && a + b < 10 = Just [Aperto (a + b)]
turno_finale _                      = Nothing

{- La funzione aggiungi antepone un turno alla lista dei turni gia'
   calcolati, propagando l'eventuale esito negativo dell'analisi dei
   turni successivi:
   - il primo argomento e' il turno da anteporre;
   - il secondo argomento e' l'esito dell'analisi dei turni
     successivi. -}
aggiungi :: Turno -> Maybe [Turno] -> Maybe [Turno]
aggiungi _ Nothing      = Nothing
aggiungi t (Just altri) = Just (t : altri)

{- La funzione somma_primi calcola la somma dei primi lanci di una
   sequenza ed e' lo strumento con cui i turni chiusi con strike o con
   spare leggono in avanti i lanci successivi:
   - il primo argomento e' il numero di lanci da sommare;
   - il secondo argomento e' la sequenza dei lanci.
   Caso base: non resta alcun lancio da sommare.
   Caso degenere: la sequenza e' esaurita prima del previsto, situazione
   che si presenta soltanto in una partita incompleta e che viene poi
   respinta dal calcolo del decimo turno.
   Caso generale: il primo lancio contribuisce alla somma dei
   rimanenti. -}
somma_primi :: Int -> [Int] -> Int
somma_primi 0 _           = 0
somma_primi _ []          = 0
somma_primi n (a : resto) = a + somma_primi (n - 1) resto

{- La funzione bonus_validi verifica che i due lanci di bonus del decimo
   turno siano ammissibili:
   - il primo argomento e' il primo lancio di bonus;
   - il secondo argomento e' il secondo lancio di bonus.
   Caso base: il primo bonus abbatte tutti i birilli, che vengono percio'
   ricomposti, e il secondo bonus e' libero di assumere qualsiasi valore.
   Caso generale: i due bonus insistono sulla stessa disposizione di
   birilli e devono percio' formare una coppia ammissibile. -}
bonus_validi :: Int -> Int -> Bool
bonus_validi 10 c = lancio_valido c
bonus_validi b c  = coppia_valida b c

{- La funzione coppia_valida verifica che due lanci effettuati sulla
   stessa disposizione di birilli siano ammissibili, ovvero che non ne
   abbattano complessivamente piu' di dieci:
   - il primo argomento e' il primo dei due lanci;
   - il secondo argomento e' il secondo dei due lanci. -}
coppia_valida :: Int -> Int -> Bool
coppia_valida a b = lancio_valido a && lancio_valido b && a + b <= 10

{- La funzione lancio_valido verifica che un lancio abbatta un numero di
   birilli compreso tra zero e dieci:
   - il suo unico argomento e' il lancio da verificare. -}
lancio_valido :: Int -> Bool
lancio_valido a = a >= 0 && a <= 10

{- La funzione righe costruisce il prospetto dei turni sotto forma di
   lista di righe di testo:
   - il primo argomento e' il numero del primo turno da presentare;
   - il secondo argomento e' la lista dei turni;
   - il terzo argomento e' la lista dei corrispondenti punteggi
     cumulativi. -}
righe :: Int -> [Turno] -> [Int] -> [String]
righe _ []          _              = []
righe _ _           []             = []
righe n (t : altri) (c : restanti) = riga n t c
                                     : righe (n + 1) altri restanti

{- La funzione riga costruisce la riga di testo relativa a un singolo
   turno, riportandone il numero, il punteggio, il totale parziale della
   partita e il modo di chiusura del turno:
   - il primo argomento e' il numero del turno;
   - il secondo argomento e' il turno da presentare;
   - il terzo argomento e' il punteggio cumulativo al termine del
     turno. -}
riga :: Int -> Turno -> Int -> String
riga n t c = "Turno " ++ allinea 2 (show n) ++
             ":  punteggio " ++ allinea 2 (show (punteggio t)) ++
             "   totale parziale " ++ allinea 3 (show c) ++
             "   (" ++ nome_turno t ++ ")"

{- La funzione allinea allinea a destra una stringa entro una larghezza
   prefissata, anteponendo gli spazi necessari, in modo che le colonne
   del prospetto risultino incolonnate:
   - il primo argomento e' la larghezza desiderata;
   - il secondo argomento e' la stringa da allineare. -}
allinea :: Int -> String -> String
allinea l s | length s >= l = s
            | otherwise     = allinea l (' ' : s)

{- La funzione nome_turno restituisce la descrizione testuale del modo
   di chiusura di un turno:
   - il suo unico argomento e' il turno da descrivere. -}
nome_turno :: Turno -> String
nome_turno (Strike _) = "strike"
nome_turno (Spare  _) = "spare"
nome_turno (Aperto _) = "turno aperto"

{- La funzione totali calcola la lista dei punteggi cumulativi, ovvero
   il totale della partita al termine di ciascun turno:
   - il primo argomento e' il totale accumulato nei turni precedenti;
   - il secondo argomento e' la lista dei turni ancora da considerare. -}
totali :: Int -> [Turno] -> [Int]
totali _   []          = []
totali acc (t : altri) = totale : totali totale altri
                         where totale = acc + punteggio t

{- La funzione punteggio_totale calcola il punteggio complessivo della
   partita sommando i punteggi dei singoli turni:
   - il suo unico argomento e' la lista dei turni della partita. -}
punteggio_totale :: [Turno] -> Int
punteggio_totale []          = 0
punteggio_totale (t : altri) = punteggio t + punteggio_totale altri

{- La funzione punteggio restituisce il punteggio di un turno,
   indipendentemente dal modo di chiusura del turno:
   - il suo unico argomento e' il turno di cui calcolare il
     punteggio. -}
punteggio :: Turno -> Int
punteggio (Strike p) = p
punteggio (Spare  p) = p
punteggio (Aperto p) = p