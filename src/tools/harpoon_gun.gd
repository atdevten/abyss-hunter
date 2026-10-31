class_name HarpoonGun
extends Node2D
## Fires [Harpoon]s from its position toward the mouse on left click, with a reload
## time between shots. Costs no oxygen. Add as a child of the diver.
## Implements Story 002 (production/epics/abyss-hunter/story-002-harpoon-camera-flash.md).
##
## Usage:
## [codeblock]
## var gun := HarpoonGun.new()
## gun.config = load("res://src/tools/tools_config.tres")
## diver.add_child(gun)
## gun.target_hit.connect(func(target: CollisionObject2D, weak: bool) -> void: print(target, weak))
## [/codeblock]

const HARPOON_SCENE: PackedScene = preload("res://src/tools/harpoon.tscn")

## Emitted when a harpoon leaves the gun.
signal harpoon_fired(harpoon: Harpoon)
## Relayed from any of this gun's harpoons. See [Harpoon] for the creature contract.
signal target_hit(target: CollisionObject2D, is_weak_spot: bool)

## Injected tuning data. Must be set before the node enters the tree.
@export var config: ToolsConfig

var _reload_left: float = 0.0


func _physics_process(delta: float) -> void:
	_reload_left = maxf(_reload_left - delta, 0.0)


func _unhandled_input(event: InputEvent) -> void:
	var mouse := event as InputEventMouseButton
	if mouse and mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
		fire_at(get_global_mouse_position())


## True when the reload time since the last shot has passed.
func is_ready() -> bool:
	return _reload_left <= 0.0


## Fires one harpoon toward [param global_target] if reloaded and the target is not
## this gun's own position. Returns whether a harpoon was fired.
func fire_at(global_target: Vector2) -> bool:
	var direction: Vector2 = global_target - global_position
	if not is_ready() or direction.is_zero_approx():
		return false
	_reload_left = config.harpoon_reload_time
	var harpoon: Harpoon = HARPOON_SCENE.instantiate()
	harpoon.launch(config, global_position, direction)
	harpoon.target_hit.connect(target_hit.emit)
	add_child(harpoon)
	harpoon_fired.emit(harpoon)
	return true
