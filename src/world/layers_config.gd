class_name LayersConfig
extends Resource
## Tuning data for the ocean's depth layers and the creature reactions to light.
## Distances are in pixels, times in seconds, depths in meters.
## Implements Story 004 (production/epics/abyss-hunter/story-004-depth-layers-lamp.md).
##
## Usage:
## [codeblock]
## var config: LayersConfig = load("res://src/world/layers_config.tres")
## var layer: LayerData = config.layers[config.get_layer_index(80.0)]
## [/codeblock]

@export_group("Layers")
## The layers, shallow to deep, by ascending [member LayerData.start_depth]; the first starts at 0.
@export var layers: Array[LayerData] = []
## Meters above each layer boundary over which the light and water blend into the next layer.
@export var blend_depth: float = 12.0
## Color drawn above the water surface.
@export var sky_color: Color = Color(0.75, 0.88, 1.0)

@export_group("Lamp Reactions")
## In an ATTRACT layer, lamp-drawn species within this distance of the lamp swim to it.
@export var lamp_attract_radius: float = 420.0
## Lamp-drawn fish hover this far from the lamp instead of swimming into it.
@export var lamp_hold_distance: float = 70.0
## In an ATTRACT layer, a patrolling predator follows lamp-drawn fish within this distance.
@export var prey_follow_radius: float = 900.0
## In a REPEL layer, creatures within this distance of the white lamp move away.
@export var lamp_repel_radius: float = 340.0

@export_group("Flash Lure")
## Predators within this distance of a camera flash in a flash-lure layer swim to it.
@export var flash_lure_radius: float = 600.0
## Seconds a flash keeps luring predators.
@export var flash_lure_duration: float = 6.0
## Radius of the flash's light in pixels (visual).
@export var flash_light_radius: float = 220.0


## Index into [member layers] of the layer containing [param depth] (meters).
func get_layer_index(depth: float) -> int:
	var index: int = 0
	for i in layers.size():
		if depth >= layers[i].start_depth:
			index = i
	return index


## [param from] blended toward [param to] over the [member blend_depth] meters above
## the start of the layer after [param index], at [param depth].
func blend_toward_next(index: int, depth: float, from: Color, to: Color) -> Color:
	if index + 1 >= layers.size():
		return from
	var boundary: float = layers[index + 1].start_depth
	return from.lerp(to, clampf((depth - (boundary - blend_depth)) / blend_depth, 0.0, 1.0))


## Ambient light color at [param depth]: the layer's, blending into the next one near the boundary.
func get_ambient_color(depth: float) -> Color:
	var index: int = get_layer_index(depth)
	var next: LayerData = layers[mini(index + 1, layers.size() - 1)]
	return blend_toward_next(index, depth, layers[index].ambient_color, next.ambient_color)
