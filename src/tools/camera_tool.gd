class_name CameraTool
extends Node2D
## Underwater camera. Right click takes a photo of the frame centered on the mouse:
## each creature in the frame emits [signal photo_taken]; nothing is harmed. Every
## photo fires a flash that briefly lights the frame and emits [signal flash_fired]
## (the dark layer and creatures react to it in Story 004). Has a cooldown; costs
## no oxygen. Add as a child of the diver. Creature contract: see [Harpoon].
## Implements Story 002 (production/epics/abyss-hunter/story-002-harpoon-camera-flash.md).
##
## Usage:
## [codeblock]
## var camera_tool := CameraTool.new()
## camera_tool.config = load("res://src/tools/tools_config.tres")
## diver.add_child(camera_tool)
## camera_tool.photo_taken.connect(func(species_id: StringName) -> void: print(species_id))
## [/codeblock]

## Emitted once per creature inside the frame when a photo is taken.
signal photo_taken(species_id: StringName)
## Emitted on every photo with the frame center in global coordinates.
signal flash_fired(position: Vector2)

## Injected tuning data. Must be set before the node enters the tree.
@export var config: ToolsConfig

var _cooldown_left: float = 0.0
var _flash_left: float = 0.0
var _flash_rect: Rect2


func _ready() -> void:
	top_level = true # draws the frame and flash in world coordinates


func _physics_process(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	_flash_left = maxf(_flash_left - delta, 0.0)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	var mouse := event as InputEventMouseButton
	if mouse and mouse.pressed and mouse.button_index == MOUSE_BUTTON_RIGHT:
		take_photo(get_global_mouse_position())


## True when the cooldown since the last photo has passed.
func is_ready() -> bool:
	return _cooldown_left <= 0.0


## Takes a photo of the frame centered on [param global_center] if off cooldown.
## Returns whether a photo was taken.
func take_photo(global_center: Vector2) -> bool:
	if not is_ready():
		return false
	_cooldown_left = config.camera_cooldown
	_flash_left = config.flash_duration
	_flash_rect = Rect2(global_center - config.photo_frame_size * 0.5, config.photo_frame_size)
	var shape := RectangleShape2D.new()
	shape.size = config.photo_frame_size
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, global_center)
	query.collide_with_areas = true
	var photographed: Array[Object] = []
	for hit: Dictionary in get_world_2d().direct_space_state.intersect_shape(query):
		var collider: Object = hit.collider
		if collider.has_method("take_damage") and collider not in photographed:
			photographed.append(collider)
			photo_taken.emit(collider.species_id)
	flash_fired.emit(global_center)
	return true


func _draw() -> void:
	var mouse: Vector2 = get_global_mouse_position()
	draw_rect(Rect2(mouse - config.photo_frame_size * 0.5, config.photo_frame_size), Color(1.0, 1.0, 1.0, 0.4), false, 1.0)
	if _flash_left > 0.0:
		draw_rect(_flash_rect, Color(1.0, 1.0, 1.0, _flash_left / config.flash_duration))
