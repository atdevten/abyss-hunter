class_name Creature
extends Area2D
## One sea creature. Species differ by data ([SpeciesData]) only; behaviour comes
## from one AI component ([PassiveAI], [FleeingAI] or [PredatorAI]) added in
## [method _ready] from [member SpeciesData.ai_kind]. Moves by steering, no physics
## collisions (open water). Implements the creature contract documented on [Harpoon].
##
## Weak spot: [method is_weak_spot] remembers the harpoon's strike point (inside the
## body, see [member ToolsConfig.harpoon_penetration]); a species with
## [member SpeciesData.weak_spot_radius] 0 has none; the following
## [method take_damage] multiplies the damage by [member SpeciesData.weak_spot_multiplier]
## when it was in the weak spot, spawns a [BloodLure] at the hit point if the species
## bleeds, and starts the hit flash if the species flashes (Atolla).
## Story 005 advantages, read per species from [member CreatureContext.encyclopedia]:
## an unlocked weak-spot half rings the weak spot; an unlocked behaviour half
## highlights a predator's warning display (with its charge/leave rings) or shows
## its attack radius, and gives prey a behaviour hint (flee ring that lights up while
## fleeing, heading arrow).
## A species with [member SpeciesData.glow_radius] > 0 carries its own [GlowLight]
## (bioluminescence, the only light in a dark layer with the lamp off); a hit flash
## brightens it.
## Implements Story 003 (production/epics/abyss-hunter/story-003-species-ai-blood.md)
## and the glow of Story 004 (production/epics/abyss-hunter/story-004-depth-layers-lamp.md).
##
## Usage:
## [codeblock]
## const CREATURE_SCENE: PackedScene = preload("res://src/creatures/creature.tscn")
## var creature: Creature = CREATURE_SCENE.instantiate()
## creature.species = load("res://src/creatures/species/grey_reef_shark.tres")
## creature.context = context   # shared CreatureContext
## creature.position = spawn_point
## add_child(creature)
## creature.behaviour_changed.connect(_on_behaviour_changed)
## [/codeblock]

## Group every live creature is in (fleeing AI looks up predators and schoolmates).
const GROUP := &"creatures"
## Horizontal speed below which the creature keeps its current facing, px/s.
const FACING_DEADZONE := 4.0
## Extra glow energy at the start of a hit flash, as a multiple of the glow energy (visual).
const FLASH_GLOW_BOOST := 3.0
# Story 005 advantage cues (visual placeholder art).
const WEAK_SPOT_COLOR := Color(1.0, 0.9, 0.1, 0.9)
const WARNING_HIGHLIGHT_COLOR := Color(1.0, 0.85, 0.1, 0.35)
## Warning highlight radius as a multiple of the body length.
const WARNING_HIGHLIGHT_SCALE := 0.75
const CHARGE_RING_COLOR := Color(1.0, 0.2, 0.2, 0.7)
const LEAVE_RING_COLOR := Color(0.3, 1.0, 0.4, 0.7)
const AGGRO_RING_COLOR := Color(1.0, 0.3, 0.3, 0.25)
const FLEE_RING_COLOR := Color(0.5, 0.9, 1.0, 0.25)
const FLEE_RING_ALERT_COLOR := Color(0.5, 0.9, 1.0, 0.7)
const HEADING_ARROW_COLOR := Color(0.5, 0.9, 1.0, 0.8)
## Heading arrow length in pixels per px/s of velocity.
const HEADING_ARROW_SCALE := 0.4
## Behaviours in which a prey's flee ring is drawn as alerted.
const ALERT_BEHAVIOURS: Array[StringName] = [&"flee", &"school_tight", &"lamp_scared"]

## Emitted when the AI switches behaviour (e.g. a predator's [code]display[/code]).
signal behaviour_changed(creature: Creature, behaviour: StringName)
## Emitted after damage was applied, with the damage after the weak spot multiplier.
signal damaged(creature: Creature, amount: float, is_weak_spot: bool)
## Emitted when a hit drew blood and spawned [param lure].
signal bled(creature: Creature, lure: BloodLure)
## Emitted when a hit makes a flashing species light up.
signal flashed(creature: Creature)
## Emitted when a predator's charge hit the diver, after the diver took [param damage].
signal struck_diver(creature: Creature, damage: float)
## Emitted when health reaches 0, just before the creature frees itself.
signal died(creature: Creature)

## Injected species data. Must be set before the node enters the tree.
@export var species: SpeciesData
## Injected shared world state. Must be set before the node enters the tree.
var context: CreatureContext

## Creature contract: species reported to the camera.
var species_id: StringName
var health: float
var velocity := Vector2.ZERO
## Point the creature wanders around; its spawn position.
var home_position: Vector2
## 1 when facing right (+x), -1 when facing left.
var facing: float = 1.0
## Current behaviour name, set by the AI component.
var behaviour: StringName
## True while a predator shows its warning display (drawn pose).
var display_pose: bool = false

var _ai: CreatureAI
var _hit_point: Vector2
var _hit_pending: bool = false
var _hit_weak: bool = false
var _flash_left: float = 0.0
var _glow: GlowLight


func _ready() -> void:
	add_to_group(GROUP)
	species_id = species.species_id
	health = species.health
	home_position = global_position
	var box := RectangleShape2D.new()
	box.size = species.body_size
	($Collision as CollisionShape2D).shape = box
	match species.ai_kind:
		SpeciesData.AiKind.PASSIVE:
			_ai = PassiveAI.new()
		SpeciesData.AiKind.FLEEING:
			_ai = FleeingAI.new()
		SpeciesData.AiKind.PREDATOR:
			_ai = PredatorAI.new()
	_ai.creature = self
	add_child(_ai)
	if context.population:
		context.population.register(self)
	if species.glow_radius > 0.0:
		_glow = GlowLight.new(species.glow_radius, species.glow_color, species.glow_energy)
		add_child(_glow)


func _physics_process(delta: float) -> void:
	if absf(velocity.x) > FACING_DEADZONE:
		facing = signf(velocity.x)
	_ai.think(delta)
	position += velocity * delta
	# Creatures live in the water: the surface is y = 0, so the body stays below it.
	var min_y: float = species.body_size.y * 0.5
	if global_position.y < min_y:
		global_position.y = min_y
		velocity.y = maxf(velocity.y, 0.0)
	_flash_left = maxf(_flash_left - delta, 0.0)
	if _glow:
		_glow.position = Vector2(species.glow_offset.x * facing, species.glow_offset.y)
		if species.flash_on_hit_duration > 0.0:
			_glow.energy = species.glow_energy * (1.0 + FLASH_GLOW_BOOST * _flash_left / species.flash_on_hit_duration)
	queue_redraw()


## Moves the velocity toward [param desired] at the species' acceleration.
func steer(desired: Vector2, delta: float) -> void:
	velocity = velocity.move_toward(desired, species.acceleration * delta)


## Turns to face [param global_point] horizontally.
func face_toward(global_point: Vector2) -> void:
	if not is_equal_approx(global_point.x, global_position.x):
		facing = signf(global_point.x - global_position.x)


## Records the AI's behaviour, emitting [signal behaviour_changed] when it changes.
func set_behaviour(new_behaviour: StringName) -> void:
	if new_behaviour != behaviour:
		behaviour = new_behaviour
		behaviour_changed.emit(self, behaviour)


## Weak spot center in global coordinates, following the facing.
func get_weak_spot_global_position() -> Vector2:
	return global_position + Vector2(species.weak_spot_offset.x * facing, species.weak_spot_offset.y)


## Creature contract: true when [param global_point] lies in the weak spot. Also
## remembers the point for the [method take_damage] call that follows a harpoon hit.
func is_weak_spot(global_point: Vector2) -> bool:
	_hit_point = global_point
	_hit_pending = true
	_hit_weak = global_point.distance_to(get_weak_spot_global_position()) <= species.weak_spot_radius
	return _hit_weak


## Creature contract: applies [param amount] (times the weak spot multiplier when the
## preceding [method is_weak_spot] check was in the weak spot), bleeds, flashes, dies at 0.
func take_damage(amount: float) -> void:
	if health <= 0.0:
		return
	var weak: bool = _hit_pending and _hit_weak
	var point: Vector2 = _hit_point if _hit_pending else global_position
	_hit_pending = false
	var dealt: float = amount * (species.weak_spot_multiplier if weak else 1.0)
	health = maxf(health - dealt, 0.0)
	damaged.emit(self, dealt, weak)
	if species.blood_lure_radius > 0.0:
		var lure := BloodLure.new(species.blood_lure_radius, species.blood_lure_duration)
		add_sibling(lure)
		lure.global_position = point
		bled.emit(self, lure)
	if species.flash_on_hit_duration > 0.0:
		_flash_left = species.flash_on_hit_duration
		flashed.emit(self)
	if health <= 0.0:
		# Out of every query this frame: no second hit, photo or AI lookup before the free.
		remove_from_group(GROUP)
		set_physics_process(false)
		collision_layer = 0
		died.emit(self)
		queue_free()


func _draw() -> void:
	var knows_behaviour: bool = context.encyclopedia.is_unlocked(species_id, Encyclopedia.Half.BEHAVIOUR)
	var is_predator: bool = species.ai_kind == SpeciesData.AiKind.PREDATOR
	if knows_behaviour and is_predator and display_pose:
		draw_circle(Vector2.ZERO, species.body_size.x * WARNING_HIGHLIGHT_SCALE, WARNING_HIGHLIGHT_COLOR)
	if _flash_left > 0.0:
		var glow: float = _flash_left / species.flash_on_hit_duration
		draw_circle(Vector2.ZERO, species.flash_radius * (1.5 - 0.5 * glow), Color(0.3, 0.6, 1.0, 0.45 * glow))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	match species.body_shape:
		SpeciesData.BodyShape.FISH:
			_draw_fish()
		SpeciesData.BodyShape.PUFFER:
			_draw_puffer()
		SpeciesData.BodyShape.JELLY:
			_draw_jelly()
		SpeciesData.BodyShape.SQUID:
			_draw_squid()
	if species.weak_spot_radius > 0.0 and context.encyclopedia.is_unlocked(species_id, Encyclopedia.Half.WEAK_SPOT):
		draw_circle(species.weak_spot_offset, species.weak_spot_radius, WEAK_SPOT_COLOR, false, 2.0)
	draw_set_transform(Vector2.ZERO)
	if not knows_behaviour:
		return
	if is_predator and display_pose:
		draw_circle(Vector2.ZERO, species.body_size.x * WARNING_HIGHLIGHT_SCALE, WEAK_SPOT_COLOR, false, 2.0)
		draw_circle(Vector2.ZERO, species.charge_distance, CHARGE_RING_COLOR, false, 2.0)
		draw_circle(Vector2.ZERO, species.leave_distance, LEAVE_RING_COLOR, false, 2.0)
	elif is_predator:
		draw_circle(Vector2.ZERO, species.aggro_radius, AGGRO_RING_COLOR, false, 1.0)
	else:
		if species.aggro_radius > 0.0:
			draw_circle(Vector2.ZERO, species.aggro_radius, FLEE_RING_ALERT_COLOR if behaviour in ALERT_BEHAVIOURS else FLEE_RING_COLOR, false, 1.0)
		var tip: Vector2 = velocity * HEADING_ARROW_SCALE
		draw_line(Vector2.ZERO, tip, HEADING_ARROW_COLOR, 2.0)
		draw_circle(tip, 2.5, HEADING_ARROW_COLOR)


## Fish body from a spine: in the display pose the back arches, the snout tilts up
## and the pectoral fins point straight down.
func _draw_fish() -> void:
	var length: float = species.body_size.x
	var height: float = species.body_size.y
	var arch: float = height * 0.45 if display_pose else 0.0
	var snout_tilt: float = height * 1.2 if display_pose else 0.0
	var upper := PackedVector2Array()
	var lower := PackedVector2Array()
	var steps: int = 12
	for i in steps + 1:
		var u: float = lerpf(-1.0, 1.0, float(i) / steps)
		var spine_y: float = -arch * (1.0 - u * u) - snout_tilt * maxf(u - 0.4, 0.0)
		var half: float = height * 0.5 * sqrt(maxf(1.0 - u * u, 0.0))
		upper.append(Vector2(u * length * 0.5, spine_y - half))
		if i > 0 and i < steps:
			lower.append(Vector2(u * length * 0.5, spine_y + half))
	lower.reverse()
	draw_colored_polygon(upper + lower, species.color)
	var tail := Vector2(-length * 0.5, 0.0)
	draw_colored_polygon(PackedVector2Array([tail + Vector2(4.0, 0.0), tail + Vector2(-height * 0.7, -height * 0.8), tail + Vector2(-height * 0.5, height * 0.5)]), species.color)
	var dorsal_y: float = -arch - height * 0.5
	draw_colored_polygon(PackedVector2Array([Vector2(-length * 0.05, dorsal_y + 2.0), Vector2(length * 0.12, dorsal_y + 2.0), Vector2(-length * 0.06, dorsal_y - height * 0.6)]), species.color.darkened(0.2))
	var fin_root := Vector2(length * 0.15, -arch * 0.9 + height * 0.3)
	var fin_tip: Vector2 = fin_root + (Vector2(0.0, height * 1.1) if display_pose else Vector2(-height * 0.9, height * 0.5))
	draw_colored_polygon(PackedVector2Array([fin_root + Vector2(-4.0, 0.0), fin_root + Vector2(4.0, 0.0), fin_tip]), species.color.darkened(0.3))
	var eye: Vector2 = upper[steps - 1] + Vector2(0.0, height * 0.3)
	draw_circle(eye, maxf(height * 0.08, 1.5), Color.BLACK)


func _draw_puffer() -> void:
	var radius: float = species.body_size.y * 0.5
	for i in 10:
		var direction := Vector2.from_angle(TAU * i / 10.0)
		draw_line(direction * radius, direction * radius * 1.35, species.color.darkened(0.4), 2.0)
	draw_circle(Vector2.ZERO, radius, species.color)
	draw_colored_polygon(PackedVector2Array([Vector2(-radius + 2.0, 0.0), Vector2(-radius * 1.6, -radius * 0.5), Vector2(-radius * 1.6, radius * 0.5)]), species.color)
	draw_circle(Vector2(radius * 0.5, -radius * 0.3), 2.0, Color.BLACK)


func _draw_jelly() -> void:
	var half_width: float = species.body_size.x * 0.5
	var height: float = species.body_size.y
	var bell := PackedVector2Array()
	for i in 13:
		bell.append(Vector2.from_angle(PI + PI * i / 12.0) * Vector2(half_width, height * 0.6))
	draw_colored_polygon(bell, species.color)
	for i in 6:
		var x: float = lerpf(-half_width * 0.8, half_width * 0.8, i / 5.0)
		draw_line(Vector2(x, 0.0), Vector2(x * 1.1, height), species.color.lightened(0.2), 1.0)
	var ring: Color = Color(0.4, 0.7, 1.0) if _flash_left > 0.0 else species.color.lightened(0.3)
	draw_line(Vector2(-half_width, 0.0), Vector2(half_width, 0.0), ring, 2.0)


func _draw_squid() -> void:
	var length: float = species.body_size.x
	var height: float = species.body_size.y
	var mantle := PackedVector2Array()
	for i in 13:
		mantle.append(Vector2.from_angle(TAU * i / 13.0) * Vector2(length * 0.3, height * 0.5) + Vector2(-length * 0.15, 0.0))
	draw_colored_polygon(mantle, species.color)
	draw_colored_polygon(PackedVector2Array([Vector2(-length * 0.4, 0.0), Vector2(-length * 0.5, -height * 0.6), Vector2(-length * 0.5, height * 0.6)]), species.color.darkened(0.2))
	for i in 5:
		var y: float = lerpf(-height * 0.35, height * 0.35, i / 4.0)
		draw_line(Vector2(length * 0.1, y * 0.5), Vector2(length * 0.5, y), species.color.lightened(0.15), 3.0)
	draw_circle(Vector2(length * 0.12, -height * 0.15), height * 0.18, Color(0.9, 0.9, 0.7))
