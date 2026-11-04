# Story 010: Bioluminescence as additive sprites

> **Epic**: abyss-hunter
> **Status**: Ready
> **Layer**: Presentation
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Art bible §1 (light = information), §5 (Atolla flash 4 frames), §8 (Glow / phát quang; 16-light limit) in `design/art/art-bible.md`. Not in the brief's MVP list.

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). The 16-lights-per-canvas-item limit on Compatibility and `CanvasModulate` darkening unshaded items are unverified in the engine reference; verify by running.

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/art/art-bible.md` §1, §5, §8:*

- [ ] Creature bioluminescence (lanternfish, Atolla, squid eye) renders as additive sprites (`CanvasItemMaterial`, blend Add, light mode Unshaded), not `PointLight2D`; glow colours only Bio Cyan `#4DE8FF`, `#4080FF`, `#D9F2BF`, at most 2 alpha levels
- [ ] In the dark layer with the lamp off, the glows stay clearly visible (not dimmed to nothing by `CanvasModulate`): retained screenshot
- [ ] The Atolla flash plays as a 4-frame additive pulse and still lures predators in the dark layer (Story 004 behaviour unchanged)
- [ ] The diver's lamp and the camera flash remain lights (they light the world); only creature glow moves to sprites
- [ ] With every species and schools on screen (`--all-species` in the dark layer), no creature loses lighting: no canvas item exceeds 16 lights (count logged in a debug run)
- [ ] Desktop and Web screenshots of the dark layer with the lamp off, white lamp and red lamp
- [ ] The core-loop playtest bot still passes
- [ ] Sign-off in `production/qa/evidence/story-010-glow-sprites-evidence.md`

---

## Implementation Notes

- Replace `src/world/glow_light.gd` use on creatures; keep the lamp and flash lights.
- Placeholder glow textures (radial dots) are fine until Story 013 supplies art; the `_glow` layer naming in art bible §8 applies when real sprites arrive.
- If `CanvasModulate` darkens the glow, put glows on their own CanvasLayer or compensate their brightness (art bible §8).

---

## Out of Scope

- Story 013: final creature sprites and their `_glow` layers
- Story 011: knowledge rings

---

## Files

- `src/creatures/creature.gd`
- `src/world/glow_light.gd`
- `src/world/depth_layers.gd`
- `production/qa/evidence/story-010-glow-sprites/`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory). A retained screenshot is not waived for Visual/Feel or UI stories.*

**Story Type**: Visual/Feel
**Required evidence**: retained screenshots in `production/qa/evidence/story-010-glow-sprites/` + sign-off in `production/qa/evidence/story-010-glow-sprites-evidence.md`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/abyss-hunter/story-009-pixel-art-settings.md`
- Unlocks: `production/epics/abyss-hunter/story-013-creature-diver-sprites.md`
