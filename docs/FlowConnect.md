# Specifiche di Gioco: "FlowConnect"

## 1. Panoramica del Gioco

**FlowConnect** è un puzzle game basato su una griglia in cui il giocatore deve ruotare delle tessere per collegare una "Sorgente" a una "Terminazione". L'obiettivo è creare un percorso continuo e coeso che permetta a un flusso di colore di attraversare la griglia, superando ostacoli come ponti e teletrasporti.

Il gioco è progettato per essere intuitivo, rilassante ma anche stimolante, con una curva di difficoltà crescente.

- **Genere**: Puzzle
- **Piattaforma Target**: Mobile (iOS/Android), Web (HTML5)
- **Pubblico**: Amanti dei puzzle, giocatori casual.

## 2. Meccaniche di Gioco Principali

### a. Interazione di Base
- Il giocatore interagisce con il gioco tramite un semplice tocco (o click) su una tessera.
- Ogni tocco ruota la tessera selezionata di 90 gradi in senso orario.

### b. Obiettivo del Livello
- Un livello è completo quando viene creato un percorso ininterrotto dalla tessera "Sorgente" alla tessera "Terminazione".
- Potrebbero esserci più Sorgenti o Terminazioni nei livelli avanzati.

### c. Feedback Visivo
- Quando una tessera viene connessa correttamente al percorso che parte dalla "Sorgente", si riempie immediatamente di colore.
- Questo "flusso" di colore fornisce un feedback istantaneo al giocatore sullo stato di avanzamento.
- Al completamento del livello, l'intero percorso si illumina e appare un messaggio di vittoria.

## 3. Elementi di Gioco

### a. La Griglia
- Il campo di gioco è una griglia di dimensioni `N x M`.
- La dimensione della griglia è uno dei fattori principali per determinare la difficoltà.

### b. Le Tessere
Le tessere sono i componenti base del puzzle.

- **Tessere Standard**:
  - **Lineare (`I`)**: Un segmento dritto.
  - **Curva (`L`)**: Una curva a 90 gradi.
  - **Incrocio a T (`T`)**: Un incrocio a tre vie.
  - **Incrocio a Croce (`+`)**: Un incrocio a quattro vie.

- **Tessere Fisse (obbligatorie)**:
  - **Sorgente**: Il punto di partenza del "flusso" di colore. Non può essere ruotata.
  - **Terminazione**: Il punto di arrivo del flusso. Anche questa è fissa.

- **Tessere Speciali Avanzate**:
  - **Ponte/Tunnel**: Permette a due percorsi di incrociarsi sullo stesso tile senza connettersi. Un percorso passa "sopra" e uno "sotto".
  - **Portale/Teletrasporto**: Un connettore che trasporta il flusso da un punto della griglia a un altro (spesso sui bordi opposti).

## 4. Progettazione dei Livelli e Difficoltà

L'approccio per la generazione dei livelli rimane lo stesso: creare una soluzione e poi mescolare le tessere ruotabili. La curva di difficoltà sarà gestita introducendo progressivamente le tessere speciali.

1.  **Livelli Facili**: Solo tessere `I`, `L`. Griglie piccole.
2.  **Livelli Medi**: Introduzione delle tessere `T` e `+`. Griglie più grandi.
3.  **Livelli Difficili**: Introduzione dei **Ponti/Tunnel**.
4.  **Livelli Esperti**: Introduzione dei **Portali/Teletrasporti** e combinazioni di tutte le meccaniche.

## 5. Specifiche Tecniche di Base

### a. Struttura Dati
- **Tessera**: Un oggetto/classe con proprietà:
  - `type`: (es. 'LINE', 'CORNER', 'SOURCE', 'BRIDGE', 'PORTAL')
  - `orientation`: (0, 90, 180, 270)
  - `isFixed`: (booleano)
  - `portalId`: (opzionale, per collegare due portali)

### b. Logica di Verifica della Vittoria
- La logica di base resta un attraversamento del grafo (DFS/BFS) a partire dalla Sorgente, ma dovrà gestire correttamente la logica dei ponti (percorsi multipli sullo stesso tile) e dei portali (salti nella griglia).

## 6. Possibili Espansioni Future
- **Sistema di Aiuti (Hint System)**: Un pulsante (es. la "bacchetta magica") che rivela una mossa corretta o risolve una piccola parte del puzzle.
- **Modalità a tempo (Time Attack)**.
- **Modalità con mosse limitate**.
- **Editor di livelli** per la community.
- **Temi e Skin** personalizzabili.

## Immagini di Gioco
![[FlowConnect_1.jpg]]
![[FlowConnect_2.jpg]]
![[FlowConnect_3.jpg]]
![[FlowConnect_4.jpg]]
![[FlowConnect_5.jpg]]
