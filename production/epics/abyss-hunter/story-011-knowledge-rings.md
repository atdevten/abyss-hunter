# Story 011: Knowledge rings overlay

> **Epic**: abyss-hunter
> **Status**: Ready
> **Layer**: Presentation
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Art bible §3 (UI shape grammar; at most 1-2 hero shapes) and §7 (Vòng kiến thức trên sinh vật) in `design/art/art-bible.md`. Not in the brief's MVP list.

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7.2 | **Risk**: HIGH
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**:
N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/art/art-bible.md` §3 and §7:*

- [ ] Knowledge rings and arrows draw on an overlay that `CanvasModulate` does not tint and lights do not affect: the weak-spot ring is the same yellow in the bright and dark layers (screenshots of both)
- [ ] Ring language: 1 px lines, no fill, no additive/glow, alpha 80-90% (secondary rings ≤ 60%), pixel-aligned
- [ ] Weak spot: dashed rotating yellow ring with a centre dot
- [ ] "About to charge": a jagged / chevron ring in `#E6F0FA` or yellow, never red
- [ ] "Leave" distance: solid green ring with an outward arrow; flee ring: dotted `#E6F0FA` at 40%; heading: `#E6F0FA` arrow
- [ ] At most 1-2 creatures show their full ring set at once (nearest or targeted); the others show only their highest-priority ring, fading with distance
- [ ] The ring priority order lives in data (default: charge/leave rings while a shark is displaying, the weak spot while the harpoon is in hand, then flee rings)
- [ ] Rings still appear only for unlocked encyclopedia halves (Story 005 rules unchanged)
- [ ] Retained screenshot with several creatures in view showing the priority filtering

---

## Implementation Notes

- The rings are drawn in `creature.gd` `_draw` today and receive the layer tint; move them to an overlay (a separate CanvasLayer that follows the camera, or an unshaded/untinted node).
- The priority order is a UX decision recorded as a data default; a designer can change it without code.

---

## Out of Scope

- Story 012: HUD and screens
- Story 013: creature sprites
- Pausing or one-panel-at-a-time (UX decisions, not in this story)

---

## Files

- `src/creatures/creature.gd`
- `src/creatures/ai/predator_ai.gd`
- `src/diver/dive_test.gd`
- `production/qa/evidence/story-011-knowledge-rings/`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above*

---

## Test Evidence

*`qa.level: minimal`: tests are waived (advisory). A retained screenshot is not waived for Visual/Feel or UI stories.*

**Story Type**: UI
**Required evidence**: retained screenshots in `production/qa/evidence/story-011-knowledge-rings/`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/abyss-hunter/story-009-pixel-art-settings.md`
- Unlocks: None
