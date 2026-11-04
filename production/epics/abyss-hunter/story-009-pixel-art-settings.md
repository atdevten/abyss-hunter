# Story 009: Pixel-art project settings

> **Epic**: abyss-hunter
> **Status**: Complete
> **Layer**: Foundation
> **Type**: Visual/Feel
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-04

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Art bible §8 Asset Standards (`design/art/art-bible.md`: pixel scale, import, stretch). Not in the brief's MVP list.

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Stretch, filter and snap values come from the technical-artist's read of the current project (`stretch/mode = disabled`, `default_texture_filter = 1` Linear, snap off).

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/art/art-bible.md` §8 (Tỷ lệ pixel; Export và import):*

- [ ] Project texture filter defaults to Nearest; light gradient textures (the lamp's `GradientTexture2D`) keep Linear filtering through a per-node override
- [ ] Display stretch is `canvas_items` with aspect `keep`, base viewport 1152x648, smooth (non-integer) scaling
- [ ] `snap_2d_transforms_to_pixel` is on
- [ ] Imported pixel-art textures use no mipmaps and Lossless compression (an import preset or `.import` defaults for `assets/art/`)
- [ ] The HUD, encyclopedia, collection and boat shop screens show no clipped or overlapping text or panels at 1152x648 and at 1920x1080 (retained screenshots of each)
- [ ] The same screens checked in a Web export
- [ ] The core-loop playtest bot still passes (`godot --headless --path . --fixed-fps 60 -s res://tools/playtest/core_loop_bot.gd`)
- [ ] Sign-off in `production/qa/evidence/story-009-pixel-art-settings-evidence.md`

---

## Implementation Notes

- Art bible §8: 1 art pixel = 1 world pixel at 1152x648; the trade-off of uneven pixels at 1080p (x1.67) is accepted.
- Changing the stretch mode moves UI layout: re-check panels sized with fixed offsets (encyclopedia, collection: ±556 x ±316) and the shop's column widths.

---

## Out of Scope

- Story 010: glow sprites
- Story 012: fonts, icons, UI scale option
- Story 013: the sprites themselves

---

## Files

- `project.godot`
- `src/world/glow_light.gd`
- `production/qa/evidence/story-009-pixel-art-settings/`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory). A retained screenshot is not waived for Visual/Feel or UI stories.*

**Story Type**: Visual/Feel
**Required evidence**: retained screenshots in `production/qa/evidence/story-009-pixel-art-settings/` + sign-off in `production/qa/evidence/story-009-pixel-art-settings-evidence.md`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/abyss-hunter/story-010-glow-sprites.md`, `production/epics/abyss-hunter/story-011-knowledge-rings.md`, `production/epics/abyss-hunter/story-012-hud-readability.md`, `production/epics/abyss-hunter/story-013-creature-diver-sprites.md`

## Completion Notes
**Completed**: 2026-11-04
**Criteria**: 8/8 passing
**Deviations**: The `glow_light.gd` Linear override is a measured no-op (Light2D textures already sample Linear on Compatibility), kept as stated intent; pixels are slightly uneven at 1080p (x1.67), the trade-off the art bible accepted; pre-existing, carried to Story 012: the encyclopedia and collection panels are see-through so the HUD shows faintly behind them, and the HUD bars stick out about 6 px past the collection panel
**Test Evidence**: waived at qa.level minimal; 13 screenshots in `production/qa/evidence/story-009-pixel-art-settings/` + sign-off `production/qa/evidence/story-009-pixel-art-settings-evidence.md` (approved by atdevten, 2026-11-04)
**Reviewed by**: self, no independent review
