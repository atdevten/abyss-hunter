class_name Harpoon
extends Node2D
## One harpoon in flight. Moves in a straight line, ray-casting each physics step
## so fast shots cannot tunnel. Frees itself on hitting anything or at max range.
## Implements Story 002 (production/epics/abyss-hunter/story-002-harpoon-camera-flash.md).
##
## Creature contract (Story 003 implements it; duck-typed, checked with has_method):
## a creature is a [CollisionObject2D] (body or area) with
## [codeblock]
## var species_id: StringName
## func take_damage(amount: float) -> void
## func is_weak_spot(global_point: Vector2) -> bool
## [/codeblock]
## [code]is_weak_spot[/code] gets the strike point: the entry point plus
## [member ToolsConfig.harpoon_penetration] along the flight direction.
## Area colliders are included in the query. A collider without [code]take_damage[/code]
## (a wall, the seabed) stops the harpoon with no hit reported.
##
## Usage (normally done by [HarpoonGun]):
## [codeblock]
## var harpoon: Harpoon = HARPOON_SCENE.instantiate()
## harpoon.launch(config, global_position, aim_direction)
## add_child(harpoon)
## [/codeblock]

## Emitted when the harpoon strikes a creature, after [code]take_damage[/code] was called.
signal target_hit(target: CollisionObject2D, is_weak_spot: bool)
## Emitted when the harpoon reaches max range or strikes a non-creature, then it frees itself.
signal harpoon_lost()

var _config: ToolsConfig
var _direction: Vector2
var _travelled: float = 0.0


## Sets up the flight. Call before adding to the tree. [param direction] must be non-zero.
## The harpoon is top-level so it flies in world space independent of its parent.
func launch(config: ToolsConfig, from: Vector2, direction: Vector2) -> void:
	_config = config
	_direction = direction.normalized()
	top_level = true
	global_position = from
	rotation = _direction.angle()


func _physics_process(delta: float) -> void:
	var step: float = minf(_config.harpoon_speed * delta, _config.harpoon_max_range - _travelled)
	var target_position: Vector2 = global_position + _direction * step
	var query := PhysicsRayQueryParameters2D.create(global_position, target_position)
	query.collide_with_areas = true
	var result: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if not result.is_empty():
		global_position = result.position
		var collider: Object = result.collider
		if collider.has_method("take_damage"):
			var weak: bool = collider.is_weak_spot(result.position + _direction * _config.harpoon_penetration)
			collider.take_damage(_config.harpoon_damage)
			target_hit.emit(collider, weak)
		else:
			harpoon_lost.emit()
		queue_free()
		return
	global_position = target_position
	_travelled += step
	if _travelled >= _config.harpoon_max_range:
		harpoon_lost.emit()
		queue_free()


func _draw() -> void:
	draw_line(Vector2(-_config.harpoon_length, 0.0), Vector2.ZERO, Color.LIGHT_GRAY, 2.0)
