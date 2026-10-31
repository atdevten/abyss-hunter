class_name BloodLure
extends Node2D
## A cloud of blood left by a hunt. Attracts predators within [member radius] only
## (never map-wide) until it has faded, then emits [signal faded] and frees itself.
## Predators find lures through the [constant GROUP] group. Spawned by [Creature].
## Implements Story 003 (production/epics/abyss-hunter/story-003-species-ai-blood.md).
##
## Usage:
## [codeblock]
## var lure := BloodLure.new(species.blood_lure_radius, species.blood_lure_duration)
## add_sibling(lure)
## lure.global_position = hit_point
## [/codeblock]

## Group every live lure is in.
const GROUP := &"blood_lures"
## Drawn radius of the blood cloud when fresh, in pixels (visual only).
const CLOUD_RADIUS := 18.0

## Emitted once when the lure has faded, just before it frees itself.
signal faded(lure: BloodLure)

## Attraction radius in pixels.
var radius: float
## Total lifetime in seconds.
var duration: float
var _time_left: float


func _init(lure_radius: float, lure_duration: float) -> void:
	radius = lure_radius
	duration = lure_duration
	_time_left = lure_duration


func _ready() -> void:
	add_to_group(GROUP)


func _physics_process(delta: float) -> void:
	_time_left -= delta
	queue_redraw()
	if _time_left <= 0.0:
		remove_from_group(GROUP)
		faded.emit(self)
		queue_free()


## True when [param global_point] is within the attraction radius.
func attracts(global_point: Vector2) -> bool:
	return global_position.distance_to(global_point) <= radius


func _draw() -> void:
	var strength: float = clampf(_time_left / duration, 0.0, 1.0)
	draw_circle(Vector2.ZERO, CLOUD_RADIUS * (2.0 - strength), Color(0.75, 0.0, 0.05, 0.6 * strength))
	draw_circle(Vector2.ZERO, radius, Color(0.9, 0.1, 0.1, 0.35 * strength), false, 1.0)
