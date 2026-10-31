# Story 001: Swim, oxygen and health

> **Epic**: abyss-hunter
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-31

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 1

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 1, Player goal & fail state, Build order 1):*

- [ ] The diver swims in 2D side view: keyboard moves, with momentum and water drag (no walking, no gravity jump)
- [ ] An oxygen bar and a health bar are shown and both start full on each dive
- [ ] Oxygen drains continuously while diving, and the drain rate rises with depth (per-layer multiplier in data, not hardcoded)
- [ ] Reaching 0 oxygen ends the dive as a death
- [ ] Health drops from damage (a `take_damage` entry point other stories call); reaching 0 health ends the dive as a death
- [ ] Death emits one `diver_died` signal carrying the cause (oxygen or health) and nothing else handles respawn here (Story 006 does)
- [ ] Surface/boat position refills oxygen and health
- [ ] Drain rates, swim speed and bar maxima live in an external data resource, not in code

---

## Implementation Notes

- Godot 4.7.2, GDScript, static typing. Verify any 4.5+ API against `docs/engine-reference/godot/` before using it.
- Use `CharacterBody2D` and `move_and_slide()`; set velocity directly with water drag, no gravity.
- Keep oxygen/health logic in a node with no scene dependencies so it is unit-testable.

---

## Out of Scope

- Story 002: harpoon and camera
- Story 004: depth layers (this story only needs a depth value to scale the drain)
- Story 006: respawn, losing cargo

---

## Files

- `src/diver/diver_config.gd`
- `src/diver/diver_config.tres`
- `src/diver/diver_vitals.gd`
- `src/diver/diver.gd`
- `src/diver/vitals_hud.gd`
- `src/diver/dive_test.gd`
- `src/diver/dive_test.tscn`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory). A retained screenshot is not waived for Visual/Feel or UI stories.*

**Story Type**: Logic
**Required evidence**: `tests/unit/diver/diver_vitals_test.gd`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/abyss-hunter/story-002-harpoon-camera-flash.md`, `production/epics/abyss-hunter/story-004-depth-layers-lamp.md`

## Completion Notes
**Completed**: 2026-10-31
**Criteria**: 8/8 passing (AC-1 confirmed by playtest; AC-3–7 by a headless DiverVitals runtime check; AC-2/3 by screenshots)
**Deviations**: None
**Test Evidence**: waived at qa.level minimal; screenshots in `production/qa/evidence/story-001-swim-oxygen-health/` (01-dive-start.png, 02-oxygen-draining.png, stamp.txt)
**Reviewed by**: self, no independent review
