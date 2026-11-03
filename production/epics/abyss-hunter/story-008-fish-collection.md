# Story 008: Fish collection

> **Epic**: abyss-hunter
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-03

## Context

**GDD**: `design/game-brief.md`
**Requirement**: User request 2026-11-02 (fish collection). Not in the brief's MVP list; extends the epic's scope.

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From the user's request: a store of what the diver has caught per species. Distinct from the encyclopedia (two knowledge halves per species) and the cargo (fish sold at the boat).*

- [ ] A `Collection` object (session only, no save to disk) keeps, for each of the 6 species: fish caught, photos taken, and the deepest depth (meters) of a catch
- [ ] A kill adds to "caught" and a photo (`photo_taken`) adds to "photos"; both stay pending until the diver docks at the boat, then are committed; death discards what is still pending (same rule as the encyclopedia and the cargo)
- [ ] The deepest-catch depth is recorded where the kill happened, in meters, and is also pending until the boat
- [ ] The **C** key opens and closes the collection screen without changing what E (encyclopedia) and B (shop) do
- [ ] The screen lists the 6 species: an unmet species shows "???"; a met species shows its name, fish caught, photos, deepest catch (meters) and the depth layer of that catch
- [ ] Pending numbers show separately (for example "+2 pending") so the player sees what a death would lose
- [ ] The screen shows a totals line: "N / 6 species met" and the total fish caught
- [ ] The species list and names come from existing data (no hard-coded species list); the collection learns of kills, photos, docking and death through signals and does not change the cargo selling, the encyclopedia unlock rules or the creature AI
- [ ] Retained screenshot of the collection screen (an unmet species, a met species and pending numbers) in `production/qa/evidence/`

---

## Implementation Notes

- Reuse the encyclopedia's pending-until-boat pattern: record on the event, commit on `Boat.docked`, discard on `Boat.respawned`.
- Count a species as "met" once it has one committed catch or photo.
- Layer of a catch: `DepthLayers` / `LayersConfig.get_layer_index(depth)`.
- Debug args for unattended screenshots, in the style of `--unlock` / `--pending` (for example a preset collection and a flag to open the screen at start).

---

## Out of Scope

- Saving to disk (the brief: no save)
- Rewards or achievements for a full collection
- Changes to the encyclopedia, the cargo or the shop

---

## Files

- `src/collection/collection.gd`
- `src/collection/collection_screen.gd`
- `src/collection/collection_screen.tscn`
- `src/diver/dive_test.gd`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory). A retained screenshot is not waived for Visual/Feel or UI stories.*

**Story Type**: Integration
**Required evidence**: playtest doc or test (waived at `qa.level: minimal`), plus a retained screenshot of the screen

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/abyss-hunter/story-003-species-ai-blood.md`, `production/epics/abyss-hunter/story-005-encyclopedia.md`, `production/epics/abyss-hunter/story-006-boat-loop.md`
- Unlocks: None

## Completion Notes
**Completed**: 2026-11-03
**Criteria**: 9/9 passing (AC-4 confirmed by hand play; AC-2/3 by console output from headless runs; AC-5/6/7/9 by `screen.png`)
**Deviations**: A species with only pending catches or photos keeps its name hidden ("???") until the boat, while its pending numbers show; the C and E screens can be open at once and overlap. The story extends the epic beyond the brief's 7 MVP features (user request 2026-11-02)
**Test Evidence**: waived at qa.level minimal; screenshot in `production/qa/evidence/story-008-fish-collection/` (screen.png, stamp.txt)
**Reviewed by**: self, no independent review
