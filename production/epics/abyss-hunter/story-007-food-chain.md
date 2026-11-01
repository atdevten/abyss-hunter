# Story 007: Minimal food chain

> **Epic**: abyss-hunter
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-01

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 7

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 7, Build order 7). The brief marks this as the first thing to cut if behind schedule.*

- [ ] Each layer tracks a prey count; killing prey lowers it
- [ ] Surfacing at the boat recovers each layer's prey count toward its starting value by a data-defined amount (so the game can't soft-lock with no fish)
- [ ] When a layer's prey count falls below a data-defined threshold, its predators become more aggressive (faster, larger aggro radius)
- [ ] Below a lower threshold, predators move up into the next shallower layer
- [ ] Predators return to their own layer when prey recovers
- [ ] Thresholds, recovery amount and aggression multipliers live in external data
- [ ] A logged line or debug readout of prey counts per layer is available for tuning

---

## Implementation Notes

- A small population object per layer; creatures register and unregister on spawn and death.
- The predator's "home layer" is data; the current layer is derived from the counts.

---

## Out of Scope

- Full ecosystem simulation (explicitly out of scope in the brief)

---

## Files

- `src/ecosystem/population.gd`
- `src/ecosystem/layer_population_data.gd`
- `src/ecosystem/ecosystem_config.gd`
- `src/ecosystem/ecosystem_config.tres`
- `src/creatures/creature_context.gd`
- `src/creatures/creature.gd`
- `src/creatures/ai/creature_ai.gd`
- `src/creatures/ai/predator_ai.gd`
- `src/diver/vitals_hud.gd`
- `src/diver/dive_test.gd`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory). A retained screenshot is not waived for Visual/Feel or UI stories.*

**Story Type**: Logic
**Required evidence**: `tests/unit/ecosystem/food_chain_test.gd`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/abyss-hunter/story-003-species-ai-blood.md`, `production/epics/abyss-hunter/story-006-boat-loop.md`
- Unlocks: None
