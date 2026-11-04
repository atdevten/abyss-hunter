# Story 012: HUD and screen readability

> **Epic**: abyss-hunter
> **Status**: Ready
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Art bible §7 UI/HUD Visual Direction (`design/art/art-bible.md`: typography, iconography, contrast, key hints) and §4 (UI palette, colour-blind backups). Not in the brief's MVP list.

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/art/art-bible.md` §4 and §7:*

- [ ] One pixel font family (Regular + Bold, tabular digits) used across the HUD and all screens; if the game will be localised to Vietnamese, the font has the full set of stacked diacritics
- [ ] Gameplay text is at least 18 px at 1152x648 (body 20, screen titles 28) and every text and bar is ≥ 4.5:1 against what is directly behind it
- [ ] The HUD uses icon + number instead of sentences: heart + health, tank + oxygen, encyclopedia, cargo and money; bars have a fixed width and no longer stretch with text
- [ ] The HUD has a semi-transparent backing (~60%), sits in a corner, has no glow and no 1 px bright outline; the UI health bar uses a brighter red (~`#E0303F`)
- [ ] The prey-per-layer readout is hidden in normal play and shown only behind a debug flag or key
- [ ] A UI scale option (100 / 125 / 150%) scales the HUD and screens; text never drops below the minimum after the Web canvas shrinks
- [ ] Encyclopedia and collection states use icons (tick for unlocked, hourglass for pending, lock for locked), not colour alone
- [ ] Each panel shows its key hints at the bottom as rectangular keycaps; at the boat a context hint "B: shop" appears
- [ ] Low oxygen blinks the bar and tank icon at 2 Hz below 25% and 3 Hz below 10% (with a sound), never above 3 flashes per second
- [ ] Retained screenshot of each screen touched (HUD in the bright and dark layers, encyclopedia, collection, shop) on desktop and Web

---

## Implementation Notes

- Panel colours from art bible §4: panel `#0E1E36`, text `#E6F0FA`, accent Signal Yellow; orange pending / green unlocked are UI-only.
- Font choice needs a licence check (open-licence pixel fonts exist); record the font and licence in the story's completion notes.

---

## Out of Scope

- Pausing when a screen opens and one panel at a time (UX decisions)
- Story 011: knowledge rings
- Gamepad glyphs (key hints go through a lookup table so glyphs can be swapped later)

---

## Files

- `src/diver/vitals_hud.gd`
- `src/encyclopedia/encyclopedia_screen.gd`, `src/encyclopedia/encyclopedia_screen.tscn`
- `src/collection/collection_screen.gd`, `src/collection/collection_screen.tscn`
- `src/boat/shop.gd`, `src/boat/shop.tscn`
- `assets/art/ui/` (icons, font)
- `production/qa/evidence/story-012-hud-readability/`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory). A retained screenshot is not waived for Visual/Feel or UI stories.*

**Story Type**: UI
**Required evidence**: retained screenshot of each screen touched in `production/qa/evidence/story-012-hud-readability/`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/abyss-hunter/story-009-pixel-art-settings.md`
- Unlocks: None
