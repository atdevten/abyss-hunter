# Test Evidence: Pixel-art project settings

> **Story**: `production/epics/abyss-hunter/story-009-pixel-art-settings.md`
> **Story Type**: Visual/Feel
> **Date**: 2026-11-04
> **Tester**: Claude (captures and checks), atdevten (review and sign-off)
> **Build / Commit**: uncommitted working tree on top of `7d96f75` (project.godot + src/world/glow_light.gd changes)

---

## What Was Tested

The project's pixel-art settings from art bible §8: Nearest texture filtering by default with the lamp gradient kept Linear, `canvas_items` / `keep` stretch at a 1152x648 base with smooth scaling, pixel snap, and Lossless / no-mipmap import defaults. The existing HUD and screens were re-captured at 1152x648 and 1920x1080 on desktop, and checked in the Web export at 1920x1080.

**Acceptance criteria covered**: AC-1 to AC-8

---

## Acceptance Criteria Results

| # | Criterion (from story) | Result | Notes |
|---|----------------------|--------|-------|
| AC-1 | Project texture filter defaults to Nearest; light gradient textures keep Linear via a per-node override | PASS | `default_texture_filter=0`; override in `glow_light.gd`. Measured: Light2D textures sample Linear on Compatibility regardless, so the override changes no pixels |
| AC-2 | Stretch `canvas_items`, aspect `keep`, base 1152x648, smooth scaling | PASS | Values printed from a headless run |
| AC-3 | `snap_2d_transforms_to_pixel` is on | PASS | Printed `true` |
| AC-4 | Pixel-art textures import with no mipmaps and Lossless | PASS | `importer_defaults/texture`; a probe PNG imported with `compress/mode=0`, `mipmaps/generate=false` (probe deleted) |
| AC-5 | HUD, encyclopedia, collection, shop without clipping or overlap at 1152x648 and 1920x1080 | PASS | Uniform x1.67 scale, crisp text; no layout fixes needed |
| AC-6 | The same screens checked in a Web export | PASS | Chromium with GPU at 1920x1080, no console errors |
| AC-7 | The core-loop playtest bot still passes | PASS | 28 passed, 0 failed, 0 skipped |
| AC-8 | Sign-off | PASS | Below |

---

## Screenshots / Video

| # | Filename | What It Shows | Acceptance Criterion |
|---|----------|--------------|----------------------|
| 1 | `story-009-pixel-art-settings/hud_surface_1152x648.png` | HUD, boat, shark and pufferfish at the base size | AC-5 |
| 2 | `story-009-pixel-art-settings/hud_surface_1920x1080.png` | The same scaled x1.67, crisp text | AC-2, AC-5 |
| 3 | `story-009-pixel-art-settings/hud_dark_1152x648.png` | Dark layer, creature glows, HUD | AC-1, AC-5 |
| 4 | `story-009-pixel-art-settings/hud_dark_1920x1080.png` | Dark layer scaled; glows smooth, no stair-steps | AC-1, AC-2 |
| 5 | `story-009-pixel-art-settings/encyclopedia_1152x648.png` | Encyclopedia panel inside the window | AC-5 |
| 6 | `story-009-pixel-art-settings/encyclopedia_1920x1080.png` | Encyclopedia scaled, rows wrap without overlap | AC-5 |
| 7 | `story-009-pixel-art-settings/collection_1152x648.png` | Collection, 4 aligned columns | AC-5 |
| 8 | `story-009-pixel-art-settings/collection_1920x1080.png` | Collection scaled | AC-5 |
| 9 | `story-009-pixel-art-settings/shop_1152x648.png` | Boat shop columns | AC-5 |
| 10 | `story-009-pixel-art-settings/shop_1920x1080.png` | Shop scaled; long text wraps inside its column | AC-5 |
| 11 | `story-009-pixel-art-settings/web_dark_1920x1080.png` | Web build, dark layer | AC-6 |
| 12 | `story-009-pixel-art-settings/web_ency_1920x1080.png` | Web build, encyclopedia | AC-6 |
| 13 | `story-009-pixel-art-settings/web_shop_1920x1080.png` | Web build, shop | AC-6 |

---

## Test Conditions

- **Game state at start**: `src/diver/dive_test.tscn` with `--layer=dark`, `--unlock/--pending/--show-encyclopedia`, `--collection/--collection-pending/--show-collection`, `--money/--upgrades/--cargo/--show-shop`
- **Platform / hardware**: macOS, Godot 4.7.2 Compatibility renderer; Web export single-threaded in headed Chromium (GPU) served from localhost
- **Framerate during test**: not measured
- **Any special setup required**: desktop 1920x1080 frames captured with a capture-on-trigger script (Movie Maker records at the viewport size only)

---

## Observations

- Light2D textures already sample Linear on Compatibility, so the `glow_light.gd` override is a no-op kept to state intent.
- Pre-existing: the encyclopedia and collection panels are slightly see-through, so the HUD shows faintly behind them, and the HUD bars stick out about 6 px past the collection panel (Story 012).

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Lead (art-director / designer) | atdevten | 2026-11-04 | [x] Approved |

---

*Template: `.claude/docs/templates/test-evidence.md`*
