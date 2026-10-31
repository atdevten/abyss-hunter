# Story 006: Boat — sell, upgrade, respawn

> **Epic**: abyss-hunter
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 6

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 6, Player goal & fail state, Build order 6):*

- [ ] The diver carries caught fish (cargo) and pending photos; surfacing at the boat is the end of a successful dive
- [ ] At the boat, cargo is sold for money (value per species from data)
- [ ] The boat offers 3 upgrades: oxygen tank, harpoon, red lamp; each has a price and levels from data, bought with money
- [ ] The basic oxygen tank is not enough to reach the dark layer and return; the upgrade is
- [ ] The red lamp upgrade lets the diver see in the dark layer without creatures noticing (feeds Story 004)
- [ ] Death (`diver_died`) respawns the diver on the boat, with cargo and uncommitted photos lost, money and upgrades kept
- [ ] After the respawn the player can dive again immediately
- [ ] Retained screenshot of the boat shop screen in `production/qa/evidence/`
- [ ] Prices, levels and values in external data

---

## Implementation Notes

- Cargo and money live in one run-state object; reset only cargo and pending photos on death.
- Win state comes from Story 005.

---

## Out of Scope

- Story 007: prey numbers recovering on surfacing

---

## Files

- `src/boat/boat.tscn`
- `src/boat/shop.gd`
- `src/boat/run_state.gd`
- `src/boat/upgrades.tres`
- `tests/integration/boat/boat_loop_test.gd`
- `production/qa/evidence/boat-shop.png`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory). A retained screenshot is not waived for Visual/Feel or UI stories.*

**Story Type**: Integration
**Required evidence**: `tests/integration/boat/boat_loop_test.gd` OR playtest doc, plus a retained screenshot of the screen

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/abyss-hunter/story-001-swim-oxygen-health.md`, `production/epics/abyss-hunter/story-004-depth-layers-lamp.md`, `production/epics/abyss-hunter/story-005-encyclopedia.md`
- Unlocks: `production/epics/abyss-hunter/story-007-food-chain.md`
