# Story 005: Encyclopedia and unlockable advantages

> **Epic**: abyss-hunter
> **Status**: Ready
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 5

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 5, Player goal & fail state, Build order 5):*

- [ ] The encyclopedia has one entry per species (6) with two halves: behavior/warning half and weak-spot half
- [ ] A photo (`photo_taken`) earns the first half: behavior for prey, the warning sign for predators; a kill earns the weak-spot half
- [ ] Earned halves are pending until the diver brings them to the boat; death loses pending photo progress
- [ ] On reaching the boat, pending halves are committed and persist for the session
- [ ] A committed advantage shows in play: the warning sign is highlighted on predators, prey behavior hints appear, the weak spot is marked
- [ ] The encyclopedia screen lists species, shows each half's state (locked/unlocked), and completion count out of 6
- [ ] All 6 entries complete triggers the win state
- [ ] The Story 003 debug switch is replaced by the real unlock state
- [ ] Retained screenshot of the encyclopedia screen in `production/qa/evidence/`

---

## Implementation Notes

- Keep unlock state in one data object; no save to disk (saving is out of scope).
- Advantages are read by creatures and HUD through that object, not by direct references.

---

## Out of Scope

- Story 006: selling fish, upgrades, respawn

---

## Files

- `src/encyclopedia/encyclopedia.gd`
- `src/encyclopedia/encyclopedia_screen.tscn`
- `src/encyclopedia/entries/` (six `.tres` data files)
- `tests/integration/encyclopedia/unlock_test.gd`
- `production/qa/evidence/encyclopedia-screen.png`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory). A retained screenshot is not waived for Visual/Feel or UI stories.*

**Story Type**: Integration
**Required evidence**: `tests/integration/encyclopedia/unlock_test.gd` OR playtest doc, plus a retained screenshot of the screen

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/abyss-hunter/story-002-harpoon-camera-flash.md`, `production/epics/abyss-hunter/story-003-species-ai-blood.md`
- Unlocks: `production/epics/abyss-hunter/story-006-boat-loop.md`
