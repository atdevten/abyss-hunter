# Story 002: Harpoon gun and camera with flash

> **Epic**: abyss-hunter
> **Status**: Complete
> **Layer**: Core
> **Type**: Logic
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-31

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 4

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (MVP 4, Core loop, Build order 2 and 4):*

- [ ] The mouse aims; a click fires a harpoon from the diver toward the cursor
- [ ] The harpoon travels with a speed and range from data, then stops or is lost at max range
- [ ] A harpoon hit calls `take_damage` on a creature and reports whether the hit was on its weak spot (weak-spot test is a method creatures implement; Story 003 supplies the shapes)
- [ ] The harpoon has a reload time between shots
- [ ] A second tool, the camera, takes a photo on a separate input; a photo of a creature in frame emits `photo_taken(species_id)` and does not harm it
- [ ] The camera flash lights the frame briefly and emits `flash_fired(position)` so creatures and the dark layer (Story 004) can react
- [ ] Tool use does not cost oxygen, but the camera has a short cooldown
- [ ] Speed, range, reload, damage and cooldowns live in an external data resource

---

## Implementation Notes

- Verify the 2D physics query and `Area2D` APIs in `docs/engine-reference/godot/modules/physics.md` before use.
- Keep the harpoon a separate scene so it can be pooled later.
- The flash lure in the dark layer is built in Story 004; this story only emits the signal.

---

## Out of Scope

- Story 003: creature hit shapes and AI reactions
- Story 005: what a photo unlocks
- Story 006: the harpoon upgrade

---

## Files

- `src/tools/tools_config.gd`
- `src/tools/tools_config.tres`
- `src/tools/harpoon.gd`
- `src/tools/harpoon.tscn`
- `src/tools/harpoon_gun.gd`
- `src/tools/camera_tool.gd`
- `src/tools/test_target.gd`
- `src/diver/dive_test.gd`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory). A retained screenshot is not waived for Visual/Feel or UI stories.*

**Story Type**: Logic
**Required evidence**: `tests/unit/tools/harpoon_camera_test.gd`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/abyss-hunter/story-001-swim-oxygen-health.md`
- Unlocks: `production/epics/abyss-hunter/story-003-species-ai-blood.md`

## Completion Notes
**Completed**: 2026-10-31
**Criteria**: 8/8 passing (AC-1, 2, 5 confirmed by hand play; AC-3, 4, 6, 7 by console output and screenshot of a windowed --auto-fire run)
**Deviations**: None. Notes carried forward: HUD ProgressBars swallow clicks over the top-left bars (vitals_hud.gd, fix mouse_filter = IGNORE); Story 003 creatures must implement species_id, take_damage(amount) and is_weak_spot(global_point)
**Test Evidence**: waived at qa.level minimal; screenshots in `production/qa/evidence/story-002-harpoon-camera-flash/` (01-harpoon-flight-and-flash.png, 02-between-shots-aim-frame.png, stamp.txt)
**Reviewed by**: self, no independent review
