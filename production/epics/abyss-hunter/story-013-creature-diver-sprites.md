# Story 013: Creature and diver sprites

> **Epic**: abyss-hunter
> **Status**: Ready
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Art bible §3 (silhouettes, shark poses), §4 (palette), §5 (character direction, frames, detail budget), §8 (formats, naming, cell sizes) in `design/art/art-bible.md`. Brief "Art & audio direction" (2D side-view pixel art).

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/art/art-bible.md` §3, §4, §5, §8:*

- [ ] **Source of the art decided and recorded before production:** an artist, an AI generation tool (e.g. `/create-game-assets` or a sprite skill) with manual clean-up, or hand-made; whichever is used must meet the criteria below
- [ ] The 6 species and the diver have sprite sheets at the art bible's cell sizes (sardine and lanternfish 24x16, pufferfish and diver 32x32, Atolla 48x32, shark 112x48, squid 144x48), one shared pivot per species, named `[category]_[name]_[state]_f[N].png` under `assets/art/`
- [ ] Colours come only from the locked palette files (`assets/art/palettes/`), with the semantic colours used only where §4 allows (no red, yellow, cyan or lamp white on the diver; Atolla and squid bodies dark red)
- [ ] Every species reads as a one-colour silhouette at real size; a screenshot of all six as silhouettes is retained
- [ ] The shark has distinct patrol (6 fr loop), display (3 fr in + 2 fr hold) and charge (2 + 2 fr) animations; display reads within 0.5 s and its bounding box differs from patrol
- [ ] Minimum frames per §5: small fish 2 fr swim, medium 4 fr, large 6 fr; the diver swim 6, idle 4, shoot 3, photo 2; at least one transition frame per behaviour state
- [ ] The diver shows the head lamp (white/red lens), the harpoon or the camera (never both), and the tank upgrade (single → twin)
- [ ] Creature hit shapes and the diver hitbox are re-checked against the new sprites (the diver changes from a ~20 px circle to a 28x12 px body); harpoon weak-spot hits and the playtest bot still pass
- [ ] Glow layers (`_glow`) are used by the Story 010 additive glow
- [ ] Desktop and Web screenshots of each layer with the real sprites + sign-off in `production/qa/evidence/story-013-creature-diver-sprites-evidence.md`

---

## Implementation Notes

- Replace the `_draw` placeholder shapes in `creature.gd` and `diver.gd` with `AnimatedSprite2D` (or `Sprite2D` + frames) driven by the existing behaviour states.
- Import settings from Story 009 (Nearest, no mipmaps, Lossless).
- This story may be split per species if it proves too large (`/create-stories`).

---

## Out of Scope

- Environment art (rocks, kelp, parallax, particles) and the boat sprite: art bible §6, separate stories
- Story 012: HUD icons

---

## Files

- `assets/art/creatures/`, `assets/art/characters/diver/`, `assets/art/palettes/`
- `src/creatures/creature.gd`, `src/creatures/creature.tscn`
- `src/diver/diver.gd`
- `production/qa/evidence/story-013-creature-diver-sprites/`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory). A retained screenshot is not waived for Visual/Feel or UI stories.*

**Story Type**: Visual/Feel
**Required evidence**: retained screenshots in `production/qa/evidence/story-013-creature-diver-sprites/` + sign-off in `production/qa/evidence/story-013-creature-diver-sprites-evidence.md`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/abyss-hunter/story-009-pixel-art-settings.md`, `production/epics/abyss-hunter/story-010-glow-sprites.md`
- Unlocks: None
