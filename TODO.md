# TODO - Tubature (Water Flow Connect Game)

> 📌 **Backlog & Feature Ideas per Tubature (e Standard Multi-Repo)**

---

## 🔊 Audio & Feedback Reattivo

### 1. 💥 Effetti Sonori Dinamici di "Rottura / Disconnessione Tubatura"
Quando il giocatore clicca/ruota una casella e **diminuisce la connettività dell'acqua** (calcolando $\Delta = \text{vecchie caselle collegate} - \text{nuove caselle collegate}$):

* **$\Delta = 1$ casella (o disconnessione singola/locale):**
  - 🔨 **Effetto:** Suono di vetro rotto / crack meccanico (`assets/sounds/broken_glass.mp3` o sfx breve).
* **$3 \le \Delta < 10$ caselle (rottura intermedia di ramo):**
  - 🗣️ **Effetto:** Clip vocale in inglese *"Uh-oh!"* / *"Oh-oh!"* (`assets/sounds/voices/uhoh.mp3`).
* **$\Delta \ge 10$ caselle (rottura catastrofica dell'acquedotto):**
  - 🪄 **Effetto:** Suono magico/epico con voce che esclama *"All the more!"* (clip da far registrare all'amico Alessandro).

#### 🛠️ Note di Implementazione:
- In `lib/logic/game_notifier.dart`: intercettare l'evento di rotazione in `rotateTile(Position pos)`.
- Confrontare la lunghezza del percorso connesso prima e dopo la rotazione:
  $$\Delta = \text{connectedTilesBefore.length} - \text{connectedTilesAfter.length}$$
- Se $\Delta > 0$, invocare `AudioService.playBreakSound(delta)` passando il valore appropriato.

---

## 🚀 Visione / Meta-Idea Globale (Da Spostare / Cross-Repo)

### 2. 📋 Semantic Multi-Repo TODO Aggregator (Obsidian-Style Tasks across `~/git/*/TODO.md`)
- [ ] **Standard Standardizzato:** Tutti i repo in `~/git/*/TODO.md` usano la sintassi universale Markdown / Obsidian task (`- [ ] Task aperto`, `- [x] Task completato`, opzionale data `📅 YYYY-MM-DD` o tag `#urgenza`).
- [ ] **Cross-Repo Greppability:**
  - Pattern ultra-veloce su filesystem: `grep -rn "^- \[ \] " ~/git/*/TODO.md`
- [ ] **CLI Scanner Veloce (in Go o Rust):**
  - Utility (es. `git-todos` o integrato in `ob-pbt`) che fa il parsing concorrente istantaneo di tutti i `~/git/*/TODO.md`.
  - Output di riepilogo per repo: numero di TODO aperti, completati, ordinamento cronologico per data di scadenza / priorità.
- [ ] **Integrazione Obsidian Dataview / Vault:**
  - Possibilità per gli strumenti del vault (`ob-pbt`, dashboard) di avere una vista unificata e aggregata di tutto il debito tecnico sparso nei repository Git.
