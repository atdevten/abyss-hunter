extends Node2D
## Minimal test scene: a diver with harpoon gun and camera, a follow camera, the HUD,
## a surface line, and the Story 003 first slice: a grey reef shark and a pufferfish.
## Not the game's main scene. Prints, with a time stamp: diver death, harpoon shots
## and hits, photos, flashes, every creature behaviour change (shark display, charge,
## leave...), damage, blood lures (which predators are in range) and their fading,
## diver hits, and the knowledge switch.
## Debug user args (after `--`):
##   --start-depth=<meters>   start the dive below the surface
##   --auto-fire              fire and photograph at the shark whenever reloaded (aims
##                            at its weak spot when knowledge is on, its center when off)
##   --knowledge=on|off       encyclopedia advantages (default off); the K key toggles it
##   --all-species            also spawn sardine and lanternfish schools, an Atolla
##                            jelly and a giant squid
##   --shark-demo=<mode>      scripted diver for an unattended run:
##       leave   swim at the shark, back off once it displays -> it leaves
##       charge  swim at the shark, push in once it displays -> it charges and bites
##       hold    swim at the shark, then stay put -> display runs out -> charge
##       lure    harpoon the pufferfish -> blood lure; a near shark is lured, a far one is not
##       weak    shark below the diver, auto-fire at it: a body shot with knowledge off,
##               a gill shot with knowledge on
##       gills   shark at the diver's depth, facing it; auto-fire head-on into the gills

const CREATURE_SCENE: PackedScene = preload("res://src/creatures/creature.tscn")
const SHARK: SpeciesData = preload("res://src/creatures/species/grey_reef_shark.tres")
const PUFFERFISH: SpeciesData = preload("res://src/creatures/species/pufferfish.tres")
const SARDINE: SpeciesData = preload("res://src/creatures/species/sardine.tres")
const LANTERNFISH: SpeciesData = preload("res://src/creatures/species/lanternfish.tres")
const ATOLLA_JELLY: SpeciesData = preload("res://src/creatures/species/atolla_jelly.tres")
const GIANT_SQUID: SpeciesData = preload("res://src/creatures/species/giant_squid.tres")

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


func _ready() -> void:
	_diver = Diver.new()
	_diver.config = load("res://src/diver/diver_config.tres")
	add_child(_diver)
	_context = CreatureContext.new(_diver)
	var all_species := false
	# Debug user args, see the header.
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--start-depth="):
			_diver.position.y = arg.trim_prefix("--start-depth=").to_float() * _diver.config.pixels_per_meter
		elif arg == "--auto-fire":
			_auto_fire = true
		elif arg.begins_with("--knowledge="):
			_context.knowledge_enabled = arg.trim_prefix("--knowledge=") == "on"
		elif arg == "--all-species":
			all_species = true
		elif arg.begins_with("--shark-demo="):
			_demo = arg.trim_prefix("--shark-demo=")
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
	_diver.vitals.diver_died.connect(func(cause: DiverVitals.Cause) -> void:
		_log("diver_died: %s" % DiverVitals.Cause.keys()[cause]))
	_gun.harpoon_fired.connect(func(harpoon: Harpoon) -> void:
		_log("harpoon_fired from %s" % harpoon.global_position)
		harpoon.harpoon_lost.connect(func() -> void: _log("harpoon_lost")))
	_gun.target_hit.connect(func(target: CollisionObject2D, is_weak_spot: bool) -> void:
		_log("target_hit: %s weak_spot=%s" % [target.name, is_weak_spot]))
	_camera_tool.photo_taken.connect(func(species_id: StringName) -> void:
		_log("photo_taken: %s" % species_id))
	_camera_tool.flash_fired.connect(func(flash_position: Vector2) -> void:
		_log("flash_fired at %s" % flash_position))
	_log("knowledge: %s" % ("on" if _context.knowledge_enabled else "off"))
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
		_:
			_auto_target = _spawn(SHARK, SHARK_OFFSET, "Shark")
			_spawn(PUFFERFISH, PUFFERFISH_OFFSET, "Pufferfish")
	if all_species:
		for i in SCHOOL_SIZE:
			_spawn(SARDINE, SARDINE_SCHOOL_OFFSET + SCHOOL_SPACING * i, "Sardine%d" % i)
			_spawn(LANTERNFISH, LANTERNFISH_SCHOOL_OFFSET + SCHOOL_SPACING * i, "Lanternfish%d" % i)
		_spawn(ATOLLA_JELLY, ATOLLA_OFFSET, "AtollaJelly")
		_spawn(GIANT_SQUID, GIANT_SQUID_OFFSET, "GiantSquid")


func _physics_process(delta: float) -> void:
	_elapsed += delta
	if _demo_shark and is_instance_valid(_demo_shark):
		_run_approach_demo(delta)
	if _auto_fire and is_instance_valid(_auto_target):
		var aim: Vector2 = _auto_target.get_weak_spot_global_position() if _context.knowledge_enabled else _auto_target.global_position
		_gun.fire_at(aim)
		_camera_tool.take_photo(_auto_target.global_position)


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.physical_keycode == KEY_K:
		_context.knowledge_enabled = not _context.knowledge_enabled
		_log("knowledge: %s" % ("on" if _context.knowledge_enabled else "off"))


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
	creature.flashed.connect(func(who: Creature) -> void: _log("%s flashed" % who.name))
	creature.struck_diver.connect(func(who: Creature, damage: float) -> void:
		_log("%s struck the diver for %.0f, diver health %.0f" % [who.name, damage, _diver.vitals.health]))
	creature.died.connect(func(who: Creature) -> void: _log("%s died" % who.name))
	add_child(creature)
	return creature


func _on_creature_bled(creature: Creature, lure: BloodLure) -> void:
	_log("%s bled: blood lure spawned at %s, radius %.0f, fades in %.1fs" % [creature.name, lure.global_position, lure.radius, lure.duration])
	var source: String = creature.name
	lure.faded.connect(func(_lure: BloodLure) -> void: _log("blood lure from %s faded" % source))
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
