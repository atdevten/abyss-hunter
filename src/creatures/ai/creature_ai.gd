class_name CreatureAI
extends Node
## Base of the three AI components (passive, fleeing, predator). A [Creature] adds
## exactly one, chosen by [member SpeciesData.ai_kind], and calls [method think]
## every physics frame; the component only sets the creature's steering and
## behaviour name, the creature moves itself. Not a species hierarchy: species
## differ by data only.
## Implements Story 003 (production/epics/abyss-hunter/story-003-species-ai-blood.md).

## Distance at which a wander point counts as reached, in pixels.
const ARRIVE_DISTANCE := 8.0

## The creature this component drives. Set by the creature before adding the node.
var creature: Creature

var _wander_target: Vector2
var _wander_time_left: float = 0.0


## Decides this frame's steering. Called by the creature every physics frame.
func think(_delta: float) -> void:
	pass


## Desired velocity for idle wandering around the creature's home at cruise speed.
func wander_velocity(delta: float) -> Vector2:
	var species: SpeciesData = creature.species
	_wander_time_left -= delta
	if _wander_time_left <= 0.0 or creature.global_position.distance_to(_wander_target) <= ARRIVE_DISTANCE:
		_wander_target = creature.home_position + Vector2.from_angle(randf() * TAU) * randf() * species.wander_radius
		_wander_time_left = species.wander_retarget_time
	return creature.global_position.direction_to(_wander_target) * species.speed * species.cruise_speed_fraction
