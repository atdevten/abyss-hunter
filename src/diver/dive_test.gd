extends Node2D
## Minimal test scene: a diver with harpoon gun and camera, a follow camera, the HUD,
## a surface line, the Story 003 first slice (a grey reef shark and a pufferfish), and
## Story 004's ocean layers ([DepthLayers]) and diver lamp ([Lamp], L toggles it).
## Not the game's main scene. Prints, with a time stamp: diver death, harpoon shots
## and hits, photos, flashes, every creature behaviour change (shark display, charge,
## leave...), damage, blood lures (which predators are in range) and their fading,
## diver hits, layer changes, lamp toggles and flash lures, and (Story 005) the
## encyclopedia: photo/kill recorded, committed N, discarded N, completed (win).
## Keys: L lamp, E encyclopedia screen, B stands in for "reached the boat" (commits
## pending halves; the boat is Story 006). Diver death discards pending halves.
## Debug user args (after `--`):
##   --start-depth=<meters>   start the dive below the surface
##   --auto-fire              fire and photograph at the shark whenever reloaded (aims
##                            at its weak spot when that half is unlocked, else its center)
##   --unlock=<spec>          halves unlocked at the start (recorded, then committed).
##                            spec: all | none | <species_id>:<half>,... with half
##                            behaviour | weak_spot | both. all = 6/6 -> win state
##   --pending=<spec>         halves recorded but not yet brought to the boat (same spec)
##   --show-encyclopedia      open the encyclopedia screen at the start
##   --boat-at=<seconds>      reach the boat (commit) at that time
##   --die-at=<seconds>       kill the diver at that time (discards pending)
##   --all-species            also spawn sardine and lanternfish schools, an Atolla
##                            jelly and a giant squid
##   --shark-demo=<mode>      scripted diver for an unattended run:
##       leave   swim at the shark, back off once it displays -> it leaves
##       charge  swim at the shark, push in once it displays -> it charges and bites
##       hold    swim at the shark, then stay put -> display runs out -> charge
##       lure    harpoon the pufferfish -> blood lure; a near shark is lured, a far one is not
##       weak    shark below the diver, auto-fire at it: a body shot, or a gill shot
##               with grey_reef_shark:weak_spot unlocked
##       gills   shark at the diver's depth, facing it; auto-fire head-on into the gills
##   --layer=bright|dim|dark  start inside that layer with its species instead of the
##                            shark and pufferfish: bright sardines + pufferfish; dim
##                            lanternfish + shark; dark Atolla, giant squid, lanternfish
##   --lamp=on|off|red        lamp at the start (default off); red = the Story 006 red lamp
##   --flash-demo             one scripted camera flash below the diver after a delay

const CREATURE_SCENE: PackedScene = preload("res://src/creatures/creature.tscn")
const SHARK: SpeciesData = preload("res://src/creatures/species/grey_reef_shark.tres")
const PUFFERFISH: SpeciesData = preload("res://src/creatures/species/pufferfish.tres")
const SARDINE: SpeciesData = preload("res://src/creatures/species/sardine.tres")
const LANTERNFISH: SpeciesData = preload("res://src/creatures/species/lanternfish.tres")
const ATOLLA_JELLY: SpeciesData = preload("res://src/creatures/species/atolla_jelly.tres")
const GIANT_SQUID: SpeciesData = preload("res://src/creatures/species/giant_squid.tres")
const OCEAN_SCENE: PackedScene = preload("res://src/world/ocean.tscn")
const ENCYCLOPEDIA_BOOK: EncyclopediaBook = preload("res://src/encyclopedia/encyclopedia_book.tres")
const ENCYCLOPEDIA_SCREEN_SCENE: PackedScene = preload("res://src/encyclopedia/encyclopedia_screen.tscn")
const BOAT_KEY := KEY_B
const UNLOCK_HALVES: Dictionary[String, Array] = {
	"behaviour": [Encyclopedia.Half.BEHAVIOUR],
	"weak_spot": [Encyclopedia.Half.WEAK_SPOT],
	"both": [Encyclopedia.Half.BEHAVIOUR, Encyclopedia.Half.WEAK_SPOT],
}

# Scene layout, in pixels relative to the diver's start (layout only, not tuning).
const SHARK_OFFSET := Vector2(320.0, 120.0)
const PUFFERFISH_OFFSET := Vector2(160.0, 60.0)
const SARDINE_SCHOOL_OFFSET := Vector2(-200.0, 80.0)
const LANTERNFISH_SCHOOL_OFFSET := Vector2(-360.0, 270.0)
const ATOLLA_OFFSET := Vector2(100.0, 220.0)
const GIANT_SQUID_OFFSET := Vector2(-450.0, 340.0)
const SCHOOL_SIZE := 5
const SCHOOL_SPACING := Vector2(14.0, 9.0)
const DEMO_SHARK_OFFSET := Vector2(300.0, 0.0)
const LURE_DEMO_PUFFERFISH_OFFSET := Vector2(200.0, 0.0)
const LURE_DEMO_NEAR_SHARK_OFFSET := Vector2(450.0, 0.0)
const LURE_DEMO_FAR_SHARK_OFFSET := Vector2(-700.0, 0.0)
const WEAK_DEMO_SHARK_OFFSET := Vector2(0.0, 150.0)
const GILLS_DEMO_SHARK_OFFSET := Vector2(180.0, 0.0)
# Scripted diver in --shark-demo: swim speed (px/s), reaction delay (s), and how far
# past the shark's leave distance it backs off (px).
const DEMO_SWIM_SPEED := 150.0
const DEMO_REACT_TIME := 0.5
const DEMO_BACK_OFF_MARGIN := 20.0
# --layer: meters below the layer's start the diver begins; species layout per layer.
const LAYER_START_MARGIN := 25.0
const BRIGHT_SARDINE_OFFSET := Vector2(-260.0, 60.0)
const BRIGHT_PUFFERFISH_OFFSET := Vector2(180.0, 40.0)
const DIM_LANTERNFISH_OFFSET := Vector2(-300.0, 60.0)
const DIM_SHARK_OFFSET := Vector2(520.0, 80.0)
const DARK_ATOLLA_OFFSET := Vector2(130.0, 90.0)
const DARK_SQUID_OFFSET := Vector2(-280.0, 140.0)
const DARK_LANTERNFISH_OFFSET := Vector2(190.0, -150.0)
# --flash-demo: seconds before the flash, and where it is, relative to the diver.
const FLASH_DEMO_DELAY := 0.5
const FLASH_DEMO_OFFSET := Vector2(0.0, 350.0)

var _diver: Diver
var _gun: HarpoonGun
var _camera_tool: CameraTool
var _context: CreatureContext
var _auto_fire: bool = false
var _auto_target: Creature
var _elapsed: float = 0.0
var _demo: String = ""
var _demo_shark: Creature
var _demo_phase: int = 0
var _demo_phase_time: float = 0.0
var _ocean: DepthLayers
var _lamp: Lamp
var _flash_demo_pending: bool = false
var _encyclopedia: Encyclopedia
var _boat_at: float = INF
var _die_at: float = INF


func _ready() -> void:
	_diver = Diver.new()
	_diver.config = load("res://src/diver/diver_config.tres")
	add_child(_diver)
	_context = CreatureContext.new(_diver)
	_encyclopedia = Encyclopedia.new(ENCYCLOPEDIA_BOOK)
	_context.encyclopedia = _encyclopedia
	var unlock_spec: String = "none"
	var pending_spec: String = "none"
	var show_encyclopedia := false
	_ocean = OCEAN_SCENE.instantiate()
	_ocean.diver = _diver
	_lamp = Lamp.new()
	_lamp.config = _diver.config
	_diver.add_child(_lamp)
	var all_species := false
	var layer_set: String = ""
	var lamp_arg: String = "off"
	# Debug user args, see the header.
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--start-depth="):
			_diver.position.y = arg.trim_prefix("--start-depth=").to_float() * _diver.config.pixels_per_meter
		elif arg == "--auto-fire":
			_auto_fire = true
		elif arg.begins_with("--unlock="):
			unlock_spec = arg.trim_prefix("--unlock=")
		elif arg.begins_with("--pending="):
			pending_spec = arg.trim_prefix("--pending=")
		elif arg == "--show-encyclopedia":
			show_encyclopedia = true
		elif arg.begins_with("--boat-at="):
			_boat_at = arg.trim_prefix("--boat-at=").to_float()
		elif arg.begins_with("--die-at="):
			_die_at = arg.trim_prefix("--die-at=").to_float()
		elif arg == "--all-species":
			all_species = true
		elif arg.begins_with("--shark-demo="):
			_demo = arg.trim_prefix("--shark-demo=")
		elif arg.begins_with("--layer="):
			layer_set = arg.trim_prefix("--layer=")
			var names: Array = _ocean.config.layers.map(func(layer: LayerData) -> String: return layer.display_name)
			_diver.position.y = (_ocean.config.layers[names.find(layer_set)].start_depth + LAYER_START_MARGIN) * _diver.config.pixels_per_meter
		elif arg.begins_with("--lamp="):
			lamp_arg = arg.trim_prefix("--lamp=")
		elif arg == "--flash-demo":
			_flash_demo_pending = true
	_ocean.layer_changed.connect(func(index: int) -> void:
		var layer: LayerData = _ocean.config.layers[index]
		_log("layer_changed: %d %s at %.1f m (oxygen drain x%.1f, lamp reaction %s, flash lures %s)" % [index, layer.display_name, _diver.get_depth(), layer.oxygen_drain_multiplier, LayerData.LampReaction.keys()[layer.lamp_reaction], layer.flash_lures]))
	_ocean.flash_lure_spawned.connect(func(lure: FlashLure) -> void:
		_log("flash lure at %s, radius %.0f, fades in %.1fs" % [lure.global_position, lure.radius, lure.duration])
		lure.faded.connect(func(_lure: BloodLure) -> void: _log("flash lure faded"))
		_log_predators_in_range(lure))
	add_child(_ocean)
	_context.depth_layers = _ocean
	_context.lamp = _lamp
	_lamp.lamp_toggled.connect(func(is_on: bool) -> void:
		_log("lamp_toggled: %s (%s)" % ["on" if is_on else "off", Lamp.Mode.keys()[_lamp.mode]]))
	if lamp_arg == "red":
		_lamp.set_mode(Lamp.Mode.RED)
	_lamp.set_on(lamp_arg in ["on", "red"])
	var camera := Camera2D.new()
	_diver.add_child(camera)
	var tools_config: ToolsConfig = load("res://src/tools/tools_config.tres")
	_gun = HarpoonGun.new()
	_gun.config = tools_config
	_diver.add_child(_gun)
	_camera_tool = CameraTool.new()
	_camera_tool.config = tools_config
	_diver.add_child(_camera_tool)
	var layer := CanvasLayer.new()
	add_child(layer)
	var hud := VitalsHud.new()
	layer.add_child(hud)
	hud.bind(_diver.vitals)
	hud.bind_encyclopedia(_encyclopedia)
	var screen: EncyclopediaScreen = ENCYCLOPEDIA_SCREEN_SCENE.instantiate()
	layer.add_child(screen)
	screen.bind(_encyclopedia)
	_encyclopedia.completed.connect(func() -> void:
		_log("encyclopedia completed %d/%d: WIN - %s" % [_encyclopedia.completed_count(), ENCYCLOPEDIA_BOOK.entries.size(), ENCYCLOPEDIA_BOOK.win_message]))
	_diver.vitals.diver_died.connect(func(cause: DiverVitals.Cause) -> void:
		_log("diver_died: %s" % DiverVitals.Cause.keys()[cause])
		_log("encyclopedia: discarded %d pending halves" % _encyclopedia.discard_pending()))
	_gun.harpoon_fired.connect(func(harpoon: Harpoon) -> void:
		_log("harpoon_fired from %s" % harpoon.global_position)
		harpoon.harpoon_lost.connect(func() -> void: _log("harpoon_lost")))
	_gun.target_hit.connect(func(target: CollisionObject2D, is_weak_spot: bool) -> void:
		_log("target_hit: %s weak_spot=%s" % [target.name, is_weak_spot]))
	_camera_tool.photo_taken.connect(func(species_id: StringName) -> void:
		_log("photo_taken: %s" % species_id)
		if _encyclopedia.record_photo(species_id):
			_log("encyclopedia: photo recorded, %s behaviour half pending" % species_id))
	_camera_tool.flash_fired.connect(func(flash_position: Vector2) -> void:
		_log("flash_fired at %s" % flash_position)
		_ocean.spawn_flash_lure(flash_position))
	if unlock_spec != "none":
		_record_spec(unlock_spec)
		_reach_boat()
	_record_spec(pending_spec)
	screen.visible = screen.visible or show_encyclopedia
	match _demo:
		"leave", "charge", "hold":
			_demo_shark = _spawn(SHARK, DEMO_SHARK_OFFSET, "Shark")
		"lure":
			_auto_fire = true
			_auto_target = _spawn(PUFFERFISH, LURE_DEMO_PUFFERFISH_OFFSET, "Pufferfish")
			_spawn(SHARK, LURE_DEMO_NEAR_SHARK_OFFSET, "NearShark")
			_spawn(SHARK, LURE_DEMO_FAR_SHARK_OFFSET, "FarShark")
		"weak":
			_auto_fire = true
			_auto_target = _spawn(SHARK, WEAK_DEMO_SHARK_OFFSET, "Shark")
		"gills":
			_auto_fire = true
			_auto_target = _spawn(SHARK, GILLS_DEMO_SHARK_OFFSET, "Shark")
		_ when layer_set == "bright":
			_spawn_school(SARDINE, BRIGHT_SARDINE_OFFSET, "Sardine")
			_spawn(PUFFERFISH, BRIGHT_PUFFERFISH_OFFSET, "Pufferfish")
		_ when layer_set == "dim":
			_spawn_school(LANTERNFISH, DIM_LANTERNFISH_OFFSET, "Lanternfish")
			_spawn(SHARK, DIM_SHARK_OFFSET, "Shark")
		_ when layer_set == "dark":
			_spawn(ATOLLA_JELLY, DARK_ATOLLA_OFFSET, "AtollaJelly")
			_spawn(GIANT_SQUID, DARK_SQUID_OFFSET, "GiantSquid")
			_spawn_school(LANTERNFISH, DARK_LANTERNFISH_OFFSET, "Lanternfish")
		_:
			_auto_target = _spawn(SHARK, SHARK_OFFSET, "Shark")
			_spawn(PUFFERFISH, PUFFERFISH_OFFSET, "Pufferfish")
	if all_species:
		_spawn_school(SARDINE, SARDINE_SCHOOL_OFFSET, "Sardine")
		_spawn_school(LANTERNFISH, LANTERNFISH_SCHOOL_OFFSET, "Lanternfish")
		_spawn(ATOLLA_JELLY, ATOLLA_OFFSET, "AtollaJelly")
		_spawn(GIANT_SQUID, GIANT_SQUID_OFFSET, "GiantSquid")


func _physics_process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _boat_at:
		_boat_at = INF
		_reach_boat()
	if _elapsed >= _die_at:
		_die_at = INF
		_diver.vitals.take_damage(_diver.vitals.config.max_health)
	if _flash_demo_pending and _elapsed >= FLASH_DEMO_DELAY:
		_flash_demo_pending = false
		_camera_tool.take_photo(_diver.global_position + FLASH_DEMO_OFFSET)
	if _demo_shark and is_instance_valid(_demo_shark):
		_run_approach_demo(delta)
	if _auto_fire and is_instance_valid(_auto_target):
		var aim: Vector2 = _auto_target.get_weak_spot_global_position() if _encyclopedia.is_unlocked(_auto_target.species_id, Encyclopedia.Half.WEAK_SPOT) else _auto_target.global_position
		_gun.fire_at(aim)
		_camera_tool.take_photo(_auto_target.global_position)


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.physical_keycode == BOAT_KEY:
		_reach_boat()


## Debug stand-in for Story 006's boat: commits every pending half.
func _reach_boat() -> void:
	_log("encyclopedia: reached the boat, committed %d halves (%d/%d complete)" % [_encyclopedia.commit_pending(), _encyclopedia.completed_count(), ENCYCLOPEDIA_BOOK.entries.size()])


## Records the halves named by an --unlock / --pending spec (see the header) as
## photos and kills, so they become pending.
func _record_spec(spec: String) -> void:
	if spec == "none":
		return
	for item in spec.split(",", false):
		var parts: PackedStringArray = item.split(":")
		var ids: Array = ENCYCLOPEDIA_BOOK.entries.map(func(entry: EncyclopediaEntry) -> StringName: return entry.species_id) if parts[0] == "all" else [StringName(parts[0])]
		for species_id: StringName in ids:
			for half: Encyclopedia.Half in UNLOCK_HALVES["both" if parts[0] == "all" else parts[1]]:
				if half == Encyclopedia.Half.BEHAVIOUR:
					_encyclopedia.record_photo(species_id)
				else:
					_encyclopedia.record_kill(species_id)


func _spawn(species: SpeciesData, offset: Vector2, creature_name: String) -> Creature:
	var creature: Creature = CREATURE_SCENE.instantiate()
	creature.species = species
	creature.context = _context
	creature.name = creature_name
	creature.position = _diver.position + offset
	creature.behaviour_changed.connect(func(who: Creature, behaviour: StringName) -> void:
		_log("%s behaviour: %s (diver %.0f px away)" % [who.name, behaviour, who.global_position.distance_to(_diver.global_position)]))
	creature.damaged.connect(func(who: Creature, amount: float, is_weak_spot: bool) -> void:
		_log("%s damaged %.1f weak_spot=%s health %.1f/%.1f" % [who.name, amount, is_weak_spot, who.health, who.species.health]))
	creature.bled.connect(_on_creature_bled)
	creature.flashed.connect(func(who: Creature) -> void:
		_log("%s flashed" % who.name)
		_ocean.spawn_flash_lure(who.global_position))
	creature.struck_diver.connect(func(who: Creature, damage: float) -> void:
		_log("%s struck the diver for %.0f, diver health %.0f" % [who.name, damage, _diver.vitals.health]))
	creature.died.connect(func(who: Creature) -> void:
		_log("%s died" % who.name)
		# Only the harpoon calls take_damage, so every creature death is a kill.
		if _encyclopedia.record_kill(who.species_id):
			_log("encyclopedia: kill recorded, %s weak spot half pending" % who.species_id))
	add_child(creature)
	return creature


## Spawns [constant SCHOOL_SIZE] of [param species] from [param offset], named name0..
func _spawn_school(species: SpeciesData, offset: Vector2, base_name: String) -> void:
	for i in SCHOOL_SIZE:
		_spawn(species, offset + SCHOOL_SPACING * i, "%s%d" % [base_name, i])


func _on_creature_bled(creature: Creature, lure: BloodLure) -> void:
	_log("%s bled: blood lure spawned at %s, radius %.0f, fades in %.1fs" % [creature.name, lure.global_position, lure.radius, lure.duration])
	var source: String = creature.name
	lure.faded.connect(func(_lure: BloodLure) -> void: _log("blood lure from %s faded" % source))
	_log_predators_in_range(lure)


## Logs, for every predator, whether [param lure] is close enough to attract it.
func _log_predators_in_range(lure: BloodLure) -> void:
	for node: Node in get_tree().get_nodes_in_group(Creature.GROUP):
		var other := node as Creature
		if other.species.ai_kind == SpeciesData.AiKind.PREDATOR:
			var in_range: bool = lure.attracts(other.global_position)
			_log("  %s is %.0f px from the lure: %s" % [other.name, other.global_position.distance_to(lure.global_position), "in radius, attracted" if in_range else "out of radius, ignores it"])


## Scripted diver for --shark-demo=leave|charge|hold: approach until the shark
## displays, wait a reaction time, then back off, push in, or stay put.
func _run_approach_demo(delta: float) -> void:
	_demo_phase_time += delta
	var to_shark: Vector2 = _demo_shark.global_position - _diver.global_position
	match _demo_phase:
		0:
			if _demo_shark.behaviour == &"display":
				_demo_phase = 1
				_demo_phase_time = 0.0
			else:
				_diver.position += to_shark.normalized() * DEMO_SWIM_SPEED * delta
		1:
			if _demo_phase_time >= DEMO_REACT_TIME:
				_demo_phase = 2
				_log("demo diver: %s" % {"leave": "backing off", "charge": "pushing in", "hold": "holding still"}[_demo])
		2:
			if _demo == "leave" and to_shark.length() < _demo_shark.species.leave_distance + DEMO_BACK_OFF_MARGIN:
				_diver.position -= to_shark.normalized() * DEMO_SWIM_SPEED * delta
			elif _demo == "charge" and _demo_shark.behaviour == &"display":
				_diver.position += to_shark.normalized() * DEMO_SWIM_SPEED * delta


func _log(text: String) -> void:
	print("[t=%.2f] %s" % [_elapsed, text])


func _draw() -> void:
	draw_line(Vector2(-4000.0, 0.0), Vector2(4000.0, 0.0), Color.WHITE, 2.0)
