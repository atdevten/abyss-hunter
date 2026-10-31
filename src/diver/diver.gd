class_name Diver
extends CharacterBody2D
## Side-view swimmer: keyboard thrust with momentum and water drag, no gravity.
## Owns a [DiverVitals] and feeds it the current depth every physics frame.
##
## Usage:
## [codeblock]
## var diver := Diver.new()
## diver.config = load("res://src/diver/diver_config.tres")
## add_child(diver)   # vitals is created in _ready
## diver.vitals.diver_died.connect(_on_diver_died)
## [/codeblock]
## Controls: WASD or arrow keys (read by physical key, no InputMap entries needed).

## Injected tuning data. Must be set before the node enters the tree.
@export var config: DiverConfig

var vitals: DiverVitals


func _ready() -> void:
	vitals = DiverVitals.new(config)


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if not vitals.is_dead:
		direction = Vector2(
			float(_pressed(KEY_D, KEY_RIGHT)) - float(_pressed(KEY_A, KEY_LEFT)),
			float(_pressed(KEY_S, KEY_DOWN)) - float(_pressed(KEY_W, KEY_UP))
		).normalized()
	velocity += direction * config.swim_acceleration * delta
	velocity *= maxf(0.0, 1.0 - config.water_drag * delta)
	velocity = velocity.limit_length(config.swim_speed)
	move_and_slide()
	if position.y < 0.0: # the water surface is y = 0
		position.y = 0.0
		velocity.y = maxf(velocity.y, 0.0)
	vitals.tick(delta, get_depth())


## Current depth in meters (0 at the surface).
func get_depth() -> float:
	return position.y / config.pixels_per_meter


func _pressed(a: Key, b: Key) -> bool:
	return Input.is_physical_key_pressed(a) or Input.is_physical_key_pressed(b)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 10.0, Color.ORANGE)
