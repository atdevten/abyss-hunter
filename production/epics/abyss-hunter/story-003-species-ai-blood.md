# Story 003: Six species, three AI types and blood lure

> **Epic**: abyss-hunter
> **Status**: In Progress
> **Layer**: Core
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-31

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 3

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 3, Build order 2 and 4). This is the riskiest story: it must prove the fight is fun and that knowledge changes it.*

- [ ] First slice: a grey reef shark (predator AI) and a pufferfish (passive AI) are playable in a test scene before the other species exist
- [ ] Three AI kinds exist: passive (drifts), fleeing (runs from the diver and from predators), predator (hunts)
- [ ] The shark shows a warning display (snout up, pectoral fins down, back arched) before charging; backing away makes it leave, pushing in makes it charge
- [ ] The shark has a weak spot that takes extra harpoon damage
- [ ] A hunt (harpoon hit that draws blood) spawns a blood lure at the target; it attracts predators within a limited radius only, not map-wide, and fades over time
- [ ] The shark's attack calls `take_damage` on the diver
- [ ] A debug switch turns the encyclopedia advantages on/off; the same shark fight is played both ways and the result is noted in a short playtest note (if both play the same, the game's hook is broken)
- [ ] After the first slice: all six species exist with the AI kind from the brief (sardine, pufferfish, lanternfish, grey reef shark, Atolla jelly, giant squid)
- [ ] Species stats (speed, health, damage, sell value, aggro radius) live in per-species data resources

---

## Implementation Notes

- Reuse one creature base scene; AI kind is a component, not a subclass tree.
- Behavior-tree or state machine: pick the simpler (FSM is enough for three kinds).
- Real-world basis (from the brief's research): shark display, lanternfish schools tighten near predators, Atolla flashes when attacked.
- Verify navigation/physics APIs against `docs/engine-reference/godot/modules/` before use.

---

## Out of Scope

- Story 004: layer-specific lighting reactions (lamp, flash lure)
- Story 005: how knowledge is unlocked (this story only reads an on/off switch)
- Story 007: population changes and predators moving shallower

---

## Files

- `src/creatures/ai/creature_ai.gd`
- `src/creatures/ai/fleeing_ai.gd`
- `src/creatures/ai/passive_ai.gd`
- `src/creatures/ai/predator_ai.gd`
- `src/creatures/blood_lure.gd`
- `src/creatures/creature.gd`
- `src/creatures/creature.tscn`
- `src/creatures/creature_context.gd`
- `src/creatures/species/atolla_jelly.tres`
- `src/creatures/species/giant_squid.tres`
- `src/creatures/species/grey_reef_shark.tres`
- `src/creatures/species/lanternfish.tres`
- `src/creatures/species/pufferfish.tres`
- `src/creatures/species/sardine.tres`
- `src/creatures/species_data.gd`
- `src/tools/harpoon.gd`
- `src/tools/tools_config.gd`
- `src/diver/dive_test.gd`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory). A retained screenshot is not waived for Visual/Feel or UI stories.*

**Story Type**: Integration
**Required evidence**: `tests/integration/creatures/species_ai_test.gd` OR playtest doc

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/abyss-hunter/story-002-harpoon-camera-flash.md`
- Unlocks: `production/epics/abyss-hunter/story-004-depth-layers-lamp.md`, `production/epics/abyss-hunter/story-005-encyclopedia.md`
