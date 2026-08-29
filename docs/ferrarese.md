# 🗣️ Glossario Ferrarese — Fonetica & Ortografia

Guida alla pronuncia e ortografia del dialetto ferrarese usato in Tubature.

> **Regola d'oro**: la **J** ferrarese si pronuncia come la **Y** inglese (semivocale palatale /j/).
> Quindi "majjal" si pronuncia "mayyàl", "majjàl" si legge "mayyàl".

## Consonanti Speciali

| Grafema | Pronuncia IPA | Come in... | Esempio |
|---------|---------------|------------|---------|
| **J** / **j** | /j/ | **Y**es (inglese) | ma**jj**al → /maj'jal/ |
| **Z** | /ts/ o /dz/ | pi**zz**a | giurna**d**aza → /dʒurna'datsa/ |
| **S** tra vocali | /z/ | ro**s**a | pia**s**er → /pja'zer/ |

## Vocali Accentate

| Grafema | Pronuncia | Nota |
|---------|-----------|------|
| **à** | /a/ aperta, tonica | majj**à**l, aldamàr |
| **è** | /ɛ/ aperta | |
| **é** | /e/ chiusa | pias**é**r |

## Glossario delle Parole Usate nel Gioco

| Parola Ferrarese | Pronuncia TTS | Significato Italiano | Contesto nel gioco |
|------------------|---------------|---------------------|-------------------|
| **majjàl** | "mayyàl" | maiale | 🐷 Esclamazione di stupore/disastro (break catastrofico, Δ≥10) |
| **aldamàr** | "aldamàr" | gridare, urlare | 😤 Esclamazione di fastidio (break moderato, Δ3-9) |
| **piasér** | "piazér" | piacere | 😊 Vittoria — "Che piaser!" |
| **tubatura** | "tubatura" | tubatura/impianto | 🔧 Vittoria — "Mo' va che tubatura!" |
| **giurnadàza** | "giurnadàtsa" | giornataccia | 😩 Sconfitta — "Che giurnadaza!" |
| **ac du bàl** | "ak du bàl" | che due palle | 🥚 Easter egg (2 ampolle) — "Majjàl, ac du bàl!" |

## Note per il TTS

Quando si generano clip audio con `edge-tts` (voce `it-IT-DiegoNeural`):

- Scrivere **"mayyàl"** (con Y) perché il TTS italiano non conosce la J ferrarese
- Scrivere **"aldamàr"** (foneticamente uguale)
- Per "ac du bàl", scrivere **"ack du bàl"** per dare la giusta occlusiva

```bash
# Esempio generazione TTS
uv tool run edge-tts --voice it-IT-DiegoNeural --text "Mayyàl!" --write-media tmp-majjal.mp3
```

## Fonti

- Dialetto di Ferrara (area cispadana, Emilia-Romagna)
- Parlante: [Alessandro Verlato](https://github.com/madAle) da Portomaggiore (FE)
