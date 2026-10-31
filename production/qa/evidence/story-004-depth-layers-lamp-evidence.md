# Test Evidence: Three depth layers, visibility and lamp

> **Story**: `production/epics/abyss-hunter/story-004-depth-layers-lamp.md`
> **Story Type**: Visual/Feel
> **Date**: 2026-11-01
> **Tester**: Claude (captures), atdevten (review and sign-off)
> **Build / Commit**: desktop captures `0d5f008`; web captures from the Web export of `56a7882` plus uncommitted Story 005 code

---

## What Was Tested

The three depth layers (bright, dim, dark) with their colour shift and darkening,
the diver's lamp in white and red mode, creature glow, creature reactions to the
lamp, and the camera flash luring a predator in the dark layer. Captured on the
desktop GL Compatibility renderer and again in a Web export (WebGL2, headed
Chromium).

**Acceptance criteria covered**: AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-8

---

## Acceptance Criteria Results

| # | Criterion (from story) | Result | Notes |
|---|----------------------|--------|-------|
| AC-1 | One ocean area has 3 layers (bright, dim, pitch-black) with depth boundaries from data; the diver's current layer is exposed to other systems | PASS | `layers_config.tres`; log `layer_changed: 2 dark at 175.0 m` |
| AC-2 | Visibility drops per layer; red fades first and the palette shifts toward blue with depth | PASS | 01, 03, 05 |
| AC-3 | The lamp toggles on/off; in the dark layer with the lamp off only creature glow is visible | PASS | 05, 09 (web) |
| AC-4 | Dim layer: the lamp draws small fish, and predators follow them | PASS | 04, 11 (web); shark following seen in the log |
| AC-5 | Dark layer: a white lamp drives most creatures away; the red lamp upgrade (Story 006) is not seen by them | PASS | 06, 10 (web), 07 (red lamp, squid on the diver) |
| AC-6 | Dark layer: a camera flash (`flash_fired`) lures predators toward its position | PASS | 08; log `GiantSquid behaviour: lured` |
| AC-7 | The oxygen-drain multiplier per layer from Story 001 is fed by the current layer | PASS | log `oxygen drain x1.5` (dim), `x2.5` (dark) |
| AC-8 | Retained screenshots of each layer, lamp on and off, saved to `production/qa/evidence/` and the same scene checked in a web export (Compatibility renderer) | PASS | 01-08 desktop, 09-12 web; no console errors in the web build |

---

## Screenshots / Video

| # | Filename | What It Shows | Acceptance Criterion |
|---|----------|--------------|----------------------|
| 1 | `story-004-depth-layers-lamp/01-bright-lamp-off.png` | Bright blue water, sardines and pufferfish clearly visible | AC-2 |
| 2 | `story-004-depth-layers-lamp/02-bright-lamp-on.png` | Lamp circle in the bright layer, no creature reaction | AC-3 |
| 3 | `story-004-depth-layers-lamp/03-dim-lamp-off.png` | Dark navy water, glowing lanternfish, muted shark | AC-2 |
| 4 | `story-004-depth-layers-lamp/04-dim-lamp-on.png` | Lanternfish gathered in the lamp light, shark approaching | AC-4 |
| 5 | `story-004-depth-layers-lamp/05-dark-lamp-off.png` | Near black; only lanternfish, Atolla and squid-eye glow | AC-2, AC-3 |
| 6 | `story-004-depth-layers-lamp/06-dark-lamp-on.png` | Faint lamp; lanternfish and squid moved away, Atolla stays | AC-5 |
| 7 | `story-004-depth-layers-lamp/07-dark-lamp-red.png` | Red lamp; squid on the diver, health about half | AC-5 |
| 8 | `story-004-depth-layers-lamp/08-dark-flash-lure.png` | Flash frame and light below the diver, squid turning to it | AC-6 |
| 9 | `story-004-depth-layers-lamp/09-web-dark-lamp-off.png` | Web build: dark layer, only creature glow | AC-3, AC-8 |
| 10 | `story-004-depth-layers-lamp/10-web-dark-lamp-on.png` | Web build: dark layer with white lamp | AC-5, AC-8 |
| 11 | `story-004-depth-layers-lamp/11-web-dim-lamp-on.png` | Web build: dim layer with lamp, shark in the light | AC-4, AC-8 |
| 12 | `story-004-depth-layers-lamp/12-web-many-lights.png` | Web build: dark layer with two squids, two Atollas, two lanternfish schools | AC-8 |

---

## Test Conditions

- **Game state at start**: `src/diver/dive_test.tscn` launched with `--layer=<bright|dim|dark>`, `--lamp=<on|off|red>`, `--flash-demo` or `--all-species`
- **Platform / hardware**: macOS, Godot 4.7.2 Compatibility renderer (desktop GL); Web export single-threaded, WebGL2 in headed Chromium served from localhost
- **Framerate during test**: not measured
- **Any special setup required**: Web launch args set in copies of the exported `index.html` (build output, not committed)

---

## Observations

- The dark layer stays very dark even with the white lamp on (06, 10); a brighter lamp is a tuning question.
- The many-lights web test reached about 15 lights, so the Compatibility limit of 16 lights per canvas item was not exceeded and remains unverified.
- With the white lamp on in the dark layer, predators flee before they can display or charge (repel radius 340 px > aggro 200-240 px); confirm this immunity is intended.
- Story 005 changed creature files after the desktop captures; the web captures include those changes.

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Lead (art-director / designer) | atdevten | 2026-11-01 | [x] Approved |

---

*Template: `.claude/docs/templates/test-evidence.md`*
