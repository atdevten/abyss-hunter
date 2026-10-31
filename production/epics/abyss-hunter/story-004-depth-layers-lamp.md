# Story 004: Three depth layers, visibility and lamp

> **Epic**: abyss-hunter
> **Status**: In Progress
> **Layer**: Feature
> **Type**: Visual/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-31

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 2

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). The Compatibility renderer is required for web; 2D lights and shadows support under it is unverified (NOT SOURCEABLE in the repo's engine reference) — check it first.

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 2, Art & audio direction, Build order 3):*

- [ ] One ocean area has 3 layers (bright, dim, pitch-black) with depth boundaries from data; the diver's current layer is exposed to other systems
- [ ] Visibility drops per layer; red fades first and the palette shifts toward blue with depth
- [ ] The lamp toggles on/off; in the dark layer with the lamp off only creature glow is visible
- [ ] Dim layer: the lamp draws small fish, and predators follow them
- [ ] Dark layer: a white lamp drives most creatures away; the red lamp upgrade (Story 006) is not seen by them
- [ ] Dark layer: a camera flash (`flash_fired`) lures predators toward its position
- [ ] The oxygen-drain multiplier per layer from Story 001 is fed by the current layer
- [ ] Retained screenshots of each layer, lamp on and off, saved to `production/qa/evidence/` and the same scene checked in a web export (Compatibility renderer)

---

## Implementation Notes

- Verify the 2D light and `CanvasModulate` behavior under the Compatibility renderer in the pinned engine docs and by running it. If it does not hold up, say so and fall back to shader-based light before building more on it.
- Run the game and screenshot it; a passing parse check is not enough.

---

## Out of Scope

- Story 003: species AI itself (this story only changes what they are drawn to)
- Story 006: buying the red lamp

---

## Files

- `src/world/layer_data.gd`
- `src/world/layers_config.gd`
- `src/world/layers_config.tres`
- `src/world/depth_layers.gd`
- `src/world/ocean.tscn`
- `src/world/glow_light.gd`
- `src/diver/lamp.gd`
- `src/creatures/flash_lure.gd`
- `src/creatures/ai/fleeing_ai.gd`
- `src/creatures/ai/passive_ai.gd`
- `src/creatures/ai/predator_ai.gd`
- `src/creatures/creature.gd`
- `src/creatures/creature_context.gd`
- `src/creatures/species_data.gd`
- `src/creatures/species/atolla_jelly.tres`
- `src/creatures/species/giant_squid.tres`
- `src/creatures/species/lanternfish.tres`
- `src/creatures/species/sardine.tres`
- `src/diver/dive_test.gd`
- `src/diver/diver_config.gd`
- `src/diver/diver_vitals.gd`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory). A retained screenshot is not waived for Visual/Feel or UI stories.*

**Story Type**: Visual/Feel
**Required evidence**: retained screenshots in `production/qa/evidence/` + sign-off in `production/qa/evidence/layers-lamp-evidence.md`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/abyss-hunter/story-001-swim-oxygen-health.md`, `production/epics/abyss-hunter/story-003-species-ai-blood.md`
- Unlocks: `production/epics/abyss-hunter/story-006-boat-loop.md`
