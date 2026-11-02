class_name Boat
extends Node2D
## The boat at the surface, where every dive starts and ends. A dive starts when the
## diver goes below [member DiverConfig.surface_depth]; it ends successfully when the
## diver comes back to the surface within [member dock_half_width] of the boat
## ([method dock]: the encyclopedia's pending halves are committed, the cargo sold,
## the vitals refilled and the [Shop] opened). Death ([signal DiverVitals.diver_died])
## respawns the diver on the boat with the cargo and pending halves lost, money and
## upgrades kept, ready to dive again. Applies the bought upgrades: oxygen tank adds
## max oxygen, harpoon adds damage, red lamp unlocks [constant Lamp.Mode].RED.
## Root of [code]src/boat/boat.tscn[/code] (the shop is its child, on a CanvasLayer).
## Implements Story 006 (production/epics/abyss-hunter/story-006-boat-loop.md).
##
## Usage:
## [codeblock]
## var boat: Boat = preload("res://src/boat/boat.tscn").instantiate()
## add_child(boat)
## boat.bind(diver, lamp, tools_config, encyclopedia, RunState.new(upgrades_config))
## boat.docked.connect(func(fish: int, earned: int, halves: int) -> void: print(fish, earned))
## [/codeblock]
## The diver and tools configs are changed in place by upgrades: pass copies.

## AT_BOAT -> DIVING when the diver goes below the surface. DIVING -> AT_BOAT when
## it docks or dies (respawn). No other transitions.
enum State { AT_BOAT, DIVING }

const OXYGEN_TANK := &"oxygen_tank"
const HARPOON := &"harpoon"
const RED_LAMP := &"red_lamp"
## Opens the shop while the diver is at the boat.
const SHOP_KEY := KEY_B
# Drawing (visual only), in pixels around the boat's origin on the waterline.
const HULL_HALF_WIDTH := 110.0
const KEEL_HALF_WIDTH := 80.0
const DECK_HEIGHT := 18.0
const KEEL_DEPTH := 16.0
const CABIN_RECT := Rect2(-50.0, -50.0, 62.0, 32.0)
const HULL_COLOR := Color(0.45, 0.27, 0.14)
const CABIN_COLOR := Color(0.93, 0.92, 0.86)
const BUOY_RADIUS := 6.0
const BUOY_COLOR := Color(1.0, 0.5, 0.1)

## Emitted when a dive ends at the boat, after selling and committing.
signal docked(fish_sold: int, money_earned: int, halves_committed: int)
## Emitted when the diver died and was put back on the boat.
signal respawned(cause: DiverVitals.Cause, fish_lost: int, halves_lost: int)
## Emitted when the diver leaves the boat for a dive.
signal dive_started()

## Horizontal distance (pixels) from the boat within which surfacing docks.
@export var dock_half_width: float = 120.0
var state: State = State.AT_BOAT
var run_state: RunState

var _diver: Diver
var _lamp: Lamp
var _tools_config: ToolsConfig
var _encyclopedia: Encyclopedia
var _base_max_oxygen: float
var _base_harpoon_damage: float

@onready var shop: Shop = $ShopLayer/Shop


## Connects the boat to the diver and the run. The current config values of
## [param diver] and [param tools_config] are the level-0 gear the bonuses add to.
func bind(diver: Diver, lamp: Lamp, tools_config: ToolsConfig, encyclopedia: Encyclopedia, run: RunState) -> void:
	_diver = diver
	_lamp = lamp
	_tools_config = tools_config
	_encyclopedia = encyclopedia
	run_state = run
	_base_max_oxygen = diver.config.max_oxygen
	_base_harpoon_damage = tools_config.harpoon_damage
	run.upgrade_changed.connect(_apply_upgrades.unbind(2))
	diver.vitals.diver_died.connect(_on_diver_died)
	shop.bind(run)
	shop.visibility_changed.connect(_on_shop_visibility_changed)
	_apply_upgrades()


func _physics_process(_delta: float) -> void:
	var at_surface: bool = _diver.get_depth() <= _diver.config.surface_depth
	match state:
		State.AT_BOAT:
			if not at_surface:
				state = State.DIVING
				dive_started.emit()
		State.DIVING:
			if at_surface and absf(_diver.global_position.x - global_position.x) <= dock_half_width:
				dock()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.physical_keycode == SHOP_KEY and state == State.AT_BOAT:
		shop.open_at_boat()


## Ends the dive at the boat: commits the encyclopedia's pending halves (which may
## complete it: the win), sells the cargo, refills the vitals and opens the shop.
## On the dock that completes the encyclopedia the shop stays closed so the win
## screen is not covered; [constant SHOP_KEY] still opens it.
func dock() -> void:
	state = State.AT_BOAT
	var halves: int = _encyclopedia.commit_pending()
	var fish: int = run_state.cargo.size()
	var earned: int = run_state.sell_cargo()
	_diver.vitals.start_dive()
	docked.emit(fish, earned, halves)
	var just_won: bool = halves > 0 and _encyclopedia.is_complete()
	if not just_won:
		shop.open_after_dive(fish, earned, halves)


func _on_diver_died(cause: DiverVitals.Cause) -> void:
	var fish: int = run_state.lose_dive()
	var halves: int = _encyclopedia.discard_pending()
	_diver.global_position = Vector2(global_position.x, 0.0) # the surface is y = 0
	_diver.velocity = Vector2.ZERO
	_diver.vitals.start_dive()
	state = State.AT_BOAT
	respawned.emit(cause, fish, halves)


## Sets the gear from the upgrade levels and refills to the new tank size (upgrades
## change only at the boat).
func _apply_upgrades() -> void:
	_diver.config.max_oxygen = _base_max_oxygen + run_state.get_bonus(OXYGEN_TANK)
	_tools_config.harpoon_damage = _base_harpoon_damage + run_state.get_bonus(HARPOON)
	_lamp.red_unlocked = run_state.get_bonus(RED_LAMP) > 0.0
	_diver.vitals.start_dive()


## The diver stays on the boat while the shop is open.
func _on_shop_visibility_changed() -> void:
	_diver.velocity = Vector2.ZERO
	_diver.set_physics_process(not shop.visible)


func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([
		Vector2(-HULL_HALF_WIDTH, -DECK_HEIGHT), Vector2(HULL_HALF_WIDTH, -DECK_HEIGHT),
		Vector2(KEEL_HALF_WIDTH, KEEL_DEPTH), Vector2(-KEEL_HALF_WIDTH, KEEL_DEPTH)]), HULL_COLOR)
	draw_rect(CABIN_RECT, CABIN_COLOR)
	for side: float in [-1.0, 1.0]:
		draw_circle(Vector2(side * dock_half_width, 0.0), BUOY_RADIUS, BUOY_COLOR)
