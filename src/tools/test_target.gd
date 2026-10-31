class_name TestTarget
extends Area2D
## TEST DUMMY for the dive test scene only, not a game creature. Implements the
## creature contract documented on [Harpoon] so hits and photos can be shown
## before Story 003 adds real creatures. Its weak spot is a small circle at
## [member weak_spot_offset].

## Species reported to the camera.
@export var species_id: StringName = &"test_dummy"
## Radius of the body hit circle in pixels.
@export var radius: float = 24.0
## Weak spot center relative to the target, in pixels.
@export var weak_spot_offset: Vector2 = Vector2(-20.0, 0.0)
## Weak spot radius in pixels.
@export var weak_spot_radius: float = 10.0

## Total damage taken so far.
var damage_taken: float = 0.0


func _ready() -> void:
	var shape := CircleShape2D.new()
	shape.radius = radius
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)


## Creature contract: records the damage.
func take_damage(amount: float) -> void:
	damage_taken += amount


## Creature contract: true when [param global_point] lies in the weak spot circle.
func is_weak_spot(global_point: Vector2) -> bool:
	return to_local(global_point).distance_to(weak_spot_offset) <= weak_spot_radius


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color.DARK_SEA_GREEN)
	draw_circle(weak_spot_offset, weak_spot_radius, Color.CRIMSON)
