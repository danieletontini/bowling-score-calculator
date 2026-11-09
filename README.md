# Bowling Score Calculator

![Haskell](https://img.shields.io/badge/Haskell-5e5086?style=flat&logo=haskell&logoColor=white)
![Prolog](https://img.shields.io/badge/Prolog-ef4d00?style=flat)
![Paradigmi](https://img.shields.io/badge/Paradigmi-Funzionale%20%7C%20Logico-blue?style=flat)
![Progetto](https://img.shields.io/badge/Tipo-Progetto%20Accademico-lightgrey?style=flat)

Un calcolatore del punteggio di una partita di bowling, implementato in **Haskell** e **Prolog**, sviluppato con l'obiettivo di analizzare e confrontare due paradigmi di programmazione distinti: la programmazione funzionale e la programmazione logica.

L'applicazione elabora una sequenza di lanci, calcola il punteggio di ciascuno dei dieci turni e determina il punteggio finale della partita, rispettando le regole standard del bowling.

Entrambe le implementazioni offrono le stesse funzionalità, adottando approcci differenti alla rappresentazione dei dati, alla ricorsione, alla validazione e alla risoluzione del problema.

---

## Panoramica

Nel bowling, il calcolo del punteggio non consiste semplicemente nella somma dei birilli abbattuti in ciascun turno. Il risultato dipende infatti da regole specifiche che coinvolgono anche i lanci successivi.

Una partita standard è composta da dieci turni, ciascuno dei quali può concludersi in uno dei seguenti modi:

| Tipo di turno | Condizione | Regola di punteggio |
|---|---|---|
| **Strike (X)** | Tutti i 10 birilli vengono abbattuti al primo lancio | 10 + i due lanci successivi |
| **Spare (/)** | Tutti i 10 birilli vengono abbattuti con due lanci | 10 + il lancio successivo |
| **Turno aperto** | Non vengono abbattuti tutti i 10 birilli | Somma dei due lanci |

Il decimo turno segue regole specifiche: uno strike dà diritto a due lanci bonus, mentre uno spare dà diritto a un lancio bonus. Questi lanci contribuiscono al punteggio finale senza generare ulteriori turni.

Di conseguenza, uno stesso lancio può contribuire al punteggio di più turni.

### Esempio

La seguente sequenza rappresenta una partita completa di bowling:

```text
Turno:      1   2   3   4    5    6   7    8    9    10
Lanci:      X   X   X  7 2  8 /  F 9   X  7 /  9 -   X X 8
Punteggio: 30  57  76  85   95  104  124  143  152   180
```

---

## Funzionalità

- Calcolo del punteggio di tutti e dieci i turni.
- Gestione di strike, spare e turni aperti.
- Corretta gestione dei lanci bonus.
- Gestione specifica delle regole del decimo turno.
- Validazione dei valori dei lanci e dei vincoli dei singoli turni.
- Rilevamento e rifiuto di sequenze di gioco non valide.
- Visualizzazione dei punteggi dei singoli turni e dei relativi totali cumulativi.
- Implementazioni equivalenti in Haskell e Prolog.

---

## Tecnologie e paradigmi di programmazione

| Tecnologia | Paradigma | Concetti principali |
|---|---|---|
| **Haskell** | Programmazione funzionale | Tipi di dati algebrici, pattern matching, ricorsione e tipo `Maybe` |
| **Prolog** | Programmazione logica | Termini composti, unificazione, predicati ricorsivi e fallimento logico |

Il progetto dimostra come uno stesso problema possa essere rappresentato e risolto attraverso paradigmi di programmazione differenti, evidenziandone i rispettivi approcci al calcolo e alla modellazione dei dati.

---

## Guida all'installazione e all'esecuzione

### Prerequisiti

Per eseguire le applicazioni sono necessari i seguenti strumenti:

- **Haskell:** Glasgow Haskell Compiler (GHC) e GHCi.
- **Prolog:** GNU Prolog.

Risorse per l'installazione:

- [GHCup – Installazione degli strumenti Haskell](https://www.haskell.org/ghcup/)
- [GNU Prolog](https://www.gprolog.org/)

### Clonazione del repository

Clonare il repository ed entrare nella directory del progetto:

```bash
git clone https://github.com/<username>/bowling-score-calculator.git
cd bowling-score-calculator
```

### Esecuzione del programma

**Haskell**

Avviare GHCi dalla directory del progetto:

```bash
ghci punteggio_bowling.hs
```

Eseguire l'azione principale:

```haskell
main
```

**Prolog**

Avviare GNU Prolog:

```bash
gprolog
```

Caricare il file sorgente ed eseguire il predicato principale:

```prolog
consult('punteggio_bowling.pl').
main.
```

---

## Formato di input e output

L'applicazione accetta una lista di numeri interi che rappresentano il numero di birilli abbattuti a ogni lancio.

Ogni valore deve essere un intero compreso tra `0` e `10`. La sequenza deve inoltre rispettare i vincoli di una partita valida e contenere il numero corretto di lanci, inclusi gli eventuali lanci bonus.

### Esempio di input

**Haskell**

```haskell
[10,10,10,7,2,8,2,0,9,10,7,3,9,0,10,10,8]
```

**Prolog**

```prolog
[10,10,10,7,2,8,2,0,9,10,7,3,9,0,10,10,8].
```

La sintassi di input differisce leggermente tra i due linguaggi: in Prolog è necessario terminare la lista con un punto.

### Esempio di output

```text
>> Punteggio dei singoli turni:
Turno  1:  punteggio 30   totale parziale  30   (strike)
Turno  2:  punteggio 27   totale parziale  57   (strike)
Turno  3:  punteggio 19   totale parziale  76   (strike)
...
Turno 10:  punteggio 28   totale parziale 180   (strike)

>> Punteggio totale della partita:
180
```

Se l'input non può essere interpretato correttamente oppure non descrive una partita valida, l'applicazione segnala l'errore e richiede l'inserimento di una nuova sequenza.

### Casi di test

| Scenario | Input | Punteggio atteso |
|---|---|---:|
| Partita perfetta | 12 strike consecutivi (`10`) | **300** |
| Punteggio minimo | 20 lanci con valore `0` | **0** |

---

## Dettagli implementativi

Entrambe le implementazioni seguono la stessa logica di calcolo e condividono una struttura concettuale comune.

### Rappresentazione dei turni

Ogni turno viene rappresentato attraverso una struttura dati dedicata, che ne identifica la tipologia e memorizza il punteggio calcolato.

**Haskell**

Il tipo di dato algebrico `Turno` definisce tre costruttori:

```haskell
data Turno = Strike Int | Spare Int | Aperto Int
```

Ciascun costruttore memorizza il punteggio del turno, comprensivo degli eventuali bonus.

**Prolog**

I turni vengono rappresentati mediante termini composti:

```prolog
strike(P)
spare(P)
aperto(P)
```

L'argomento `P` contiene il punteggio calcolato del turno.

### Algoritmo di calcolo ricorsivo

La funzione `turni` in Haskell e il predicato `turni` in Prolog elaborano ricorsivamente la sequenza dei lanci e costruiscono una lista contenente i dieci turni calcolati.

L'algoritmo distingue tre situazioni:

1. **Strike:** consuma un lancio e calcola il punteggio utilizzando i due lanci successivi.
2. **Spare:** consuma due lanci e calcola il punteggio utilizzando il lancio successivo.
3. **Turno aperto:** consuma due lanci e ne calcola la somma.

I lanci bonus vengono letti dalla sequenza residua senza essere consumati durante il calcolo del turno corrente. Successivamente vengono elaborati normalmente nell'ambito dei rispettivi turni.

Il decimo turno viene gestito separatamente attraverso la funzione e il predicato `turno_finale`, che considerano le regole specifiche relative ai lanci bonus.

### Validazione dell'input e gestione degli errori

I due linguaggi adottano meccanismi differenti per rappresentare e gestire le elaborazioni non riuscite.

| Aspetto | Haskell | Prolog |
|---|---|---|
| Analisi dell'input | `readMaybe` | `read` |
| Rappresentazione del risultato | `Maybe [Turno]` | Successo o fallimento del predicato |
| Input non valido | `Nothing` | Fallimento logico |
| Gestione dell'errore | Pattern matching su `Maybe` | Clausola alternativa del predicato e nuova acquisizione dell'input |

In Haskell, il tipo `Maybe` rappresenta esplicitamente la possibilità che l'analisi dell'input o il calcolo della partita non vadano a buon fine.

In Prolog, le sequenze non valide provocano il fallimento dei predicati corrispondenti. La clausola alternativa di `controlla_partita` gestisce questa situazione richiedendo un nuovo input.

### Confronto tra le implementazioni

| Aspetto | Haskell | Prolog |
|---|---|---|
| Modellazione dei dati | Tipi di dati algebrici | Termini composti |
| Distinzione dei casi | Pattern matching e guardie | Unificazione e clausole dei predicati |
| Computazione | Funzioni ricorsive | Predicati ricorsivi |
| Validazione | Condizioni booleane e `Maybe` | Vincoli logici e fallimento dei predicati |
| Generazione dell'output | Costruzione di stringhe e azioni IO | Predicati con `write/1` |

---

## Struttura del progetto

```text
bowling-score-calculator/
│
├── punteggio_bowling.hs    # Implementazione Haskell
├── punteggio_bowling.pl    # Implementazione Prolog
├── relazione.pdf           # Relazione del progetto
│
└── README.md               # Documentazione del progetto
```

---

## Autori

**Daniele Tontini** · **Tommaso Vincenzi**

Progetto accademico realizzato nell'ambito del corso di **Programmazione Logica e Funzionale** presso l'Università degli Studi di Urbino Carlo Bo.

---

*Il progetto è stato sviluppato a scopo didattico, con particolare attenzione al confronto tra gli approcci della programmazione funzionale e della programmazione logica nella risoluzione dello stesso problema.*