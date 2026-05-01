# AGENT.md — ZMK Config (qwertz Branch)

## Projekt-Übersicht

- **Keyboard**: splitkb Aurora Corne (3×6 + 3 Daumentasten pro Seite)
- **Branch**: `qwertz`
- **Base Layout**: Colemak-DH, angepasst für Deutsch (QWERTZ-Alphas: Ä, Ö, Ü, ß)
- **Home Row Mods**: `hml` / `hmr` mit 280ms Tapping-Term, Balanced-Flavor
- **Layer-Wechsel per Hold (`&lt`)**: Daumen-triggered

## Aktuelles Base Layer (Colemak-DH + Deutsch)

```
Linke Hälfte:                  Rechte Hälfte:
[!] [Q] [W] [F] [P] [B]   |   [J] [L] [U] [Y] ["] [?]
[Ä] [A] [R] [S] [T] [G]   |   [M] [N] [E] [I] [O] [Ö]
[ß] [Z] [X] [C] [D] [V]   |   [K] [H] [,] [.] [/] [Ü]
        [ESC] [SPC] [TAB]  |       [ENT] [BSP] [DEL]
```

**Home Row Mods (hml/hmr):**
- Links: A→Meta, R→Alt, S→Strg, T→Shift
- Rechts: N→Shift, E→Strg, I→Alt, O→Meta

## Problem / Motivation

Colemak-DH ist super zum Tippen, aber **ungenügend für Gaming**:
- WASD ist über verschiedene Reihen und Finger verteilt
- W liegt auf dem Ringfinger (statt Mittelfinger)
- Die Muskelgedächtnis-Programmierung für WASD fehlt

## Lösungsansätze

### Option A: Base Layer auf reines QWERTZ umstellen

- Base Layer wird von Colemak-DH → QWERTZ geändert
- Home Row Mods bleiben erhalten (nur andere Buchstaben)
- **Nachteil**: Tipp-Gewohnheiten müssen umgestellt werden, tägliches Tippen leidet

### Option B: Gaming Layer (persistent togglen) ⭐ EMPFOHLEN

- **Base Layer bleibt Colemak-DH** — optimal zum Tippen
- Zusätzlicher Gaming-Layer mit QWERTZ-Anordnung
- Layer kann per Toggle (Combo oder Taste) ein-/ausgeschaltet werden
- Rechte Hand bleibt frei für Maus
- **Vorteil**: Keine Kompromisse beim Tippen, bester Gaming-Komfort

## Key Position Mapping (Corne 3×6)

```
Links:                        Rechts:
Pos  0  1  2  3  4  5    |    Pos  6  7  8  9 10 11   (Top Row)
Pos 12 13 14 15 16 17    |    Pos 18 19 20 21 22 23   (Home Row)
Pos 24 25 26 27 28 29    |    Pos 30 31 32 33 34 35   (Bottom Row)
        36  37  38        |          39  40  41        (Thumb)
```

## Vorschlag: Gaming Layer Design

### Linke Hälfte (primär, da rechte Hand an der Maus)

```
TOP (0-5):     [1]  [2]  [W]  [3]  [4]  [5]
HOME (12-17):  [Q]  [A]  [S]  [D]  [F]  [G]
BOTTOM (24-29):[LSH] [Z]  [X]  [C]  [R]  [T]
THUMB (36-38): [LCTRL] [SPACE] [LALT]
```

**WARUM diese Anordnung:**

| Taste | Position | Finger | Begründung |
|-------|----------|--------|------------|
| **W** | pos 2 (Top/Mitte) | Mittelfinger ↑ | WASD-Standard, Mittelfinger geht hoch |
| **A** | pos 13 (Home/Ring) | Ringfinger | Natürliche Ringfinger-Position |
| **S** | pos 14 (Home/Mitte) | Mittelfinger | Natürliche Mittelfinger-Position |
| **D** | pos 15 (Home/Index) | Zeigefinger | Natürliche Zeigefinger-Position |
| **Q** | pos 12 (Pinky Home) | Kleinfinger | Für Quick-Switch/Ability |
| **E** | — | — | Auf rechter Seite oder Maus |
| **R** | pos 28 (Index Bottom) | Zeigefinger ↓ | Reload, gut erreichbar |
| **F** | pos 16 (Index Home) | Zeigefinger | Use/Interact |
| **1-5** | pos 0-1, 3-5 | verschiedene | Waffen-Switching |
| **LSH** | pos 24 (Pinky Bottom) | Kleinfinger ↓ | Sprint |
| **LCTRL** | pos 36 (Daumen) | Daumen | Ducken |
| **SPACE** | pos 37 (Daumen) | Daumen | Springen |
| **LALT** | pos 38 (Daumen) | Daumen | Voice Chat / Walk |

### Rechte Hälfte (sekundär)

```
TOP (6-11):    [6]  [7]  [8]  [9]  [0]  [-]
HOME (18-23): [Y]  [U]  [I]  [O]  [P]  [Ü]
BOTTOM (30-35):[B]  [N]  [M]  [,]  [.]  [ß]
THUMB (39-41): [E]  [TAB] [ESC]
```

### Toggle-Mechanismus

Ein **Combo** zum Togglen des Gaming-Layers. Vorschlag:
- **Combo auf der rechten Hand** (damit man nicht versehentlich im Base-Layer umschaltet)
- Z.B. die beiden innersten Tasten der oberen rechten Reihe (pos 10 + 11 → `"` + `?`)
- Oder: Ein `&tog` auf einem der bestehenden Layer (z.B. in der FN-Leiste)

Layer-Struktur:
```c
// Layer-Reihenfolge:
// 0 = Base (Colemak-DH)
// 1-6 = Bestehende Layer (NAV, Mouse, Media, Num, Symbols, FN)
// 7 = Gaming (QWERTZ)
```

## Umsetzung

### 1. Gaming-Layer definieren

```c
Gaming {
    bindings = <
        // --- LEFT TOP (0-5) ---             // --- RIGHT TOP (6-11) ---
        &kp N1   &kp N2   &kp W   &kp N3   &kp N4   &kp N5    &kp N6   &kp N7   &kp N8   &kp N9   &kp N0   &kp MINUS
        // --- LEFT HOME (12-17) ---          // --- RIGHT HOME (18-23) ---
        &kp Q    &kp A    &kp S   &kp D    &kp F    &kp G     &kp Y    &kp U    &kp I    &kp O    &kp P    &kp DE_O_UMLAUT
        // --- LEFT BOTTOM (24-29) ---        // --- RIGHT BOTTOM (30-35) ---
        &kp LSHIFT &kp Z  &kp X   &kp C    &kp R    &kp T     &kp B    &kp N    &kp M    &kp DE_COMMA &kp DE_DOT &kp DE_ESZETT
        // --- LEFT THUMB (36-38) ---         // --- RIGHT THUMB (39-41) ---
                  &kp LCTRL  &kp SPACE  &kp LALT  &kp E  &kp TAB  &kp ESC
    >;
};
```

### 2. Toggle-Combo

```c
GamingToggle {
    bindings = <&tog 7>;
    key-positions = <10 11>;  // " und ? auf rechter Top-Reihe
};
```

### 3. Rückkehr-Combo

```c
GamingBack {
    bindings = <&tog 0>;
    key-positions = <...>;  // z.B. auf Gaming-Layer selbst
};
```

Oder einfacher: ein Key auf dem Gaming-Layer selbst, der zurück toggled.

## ToDo

- [ ] Gaming-Layer im Keymap definieren
- [ ] Toggle-Combo einbauen (am besten ohne Kollisionen mit bestehenden Combos)
- [ ] Testen: Layer-Wechsel funktioniert?
- [ ] Testen: WASD fühlt sich natürlich an?
- [ ] Optional: Home Row Mods auf Gaming-Layer deaktivieren (stören beim Spielen)

## Notes

- Home Row Mods sollten auf dem Gaming-Layer deaktiviert sein — beim Spielen will man rohe Tastenanschläge
- Layer-Reihenfolge in ZMK: Layer 7 ist Gaming-Layer (nach den bestehenden 0-6)
- `&tog 7` toggled Layer 7 an/aus
- Wenn Layer 7 aktiv ist, werden alle darunter liegenden Layer ausgeblendet
