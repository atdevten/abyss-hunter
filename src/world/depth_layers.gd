class_name DepthLayers
extends Node2D
## The ocean's depth layers (bright, dim, pitch-black by default; all from
## [LayersConfig]). Tracks which layer the diver is in, exposes it to other systems
## ([signal layer_changed], [method get_current_layer]), feeds that layer's oxygen
## drain multiplier to the diver's vitals, lights the world through a
## [CanvasModulate] (visibility drops, red fades first, blue remains), draws the
## water, and turns camera flashes in flash-lure layers into [FlashLure]s.
## Root of [code]src/world/ocean.tscn[/code].
## Implements Story 004 (production/epics/abyss-hunter/story-004-depth-layers-lamp.md).
##
## Usage:
## [codeblock]
## var ocean: DepthLayers = preload("res://src/world/ocean.tscn").instantiate()
## ocean.diver = diver                  # must be in the tree already (vitals exist)
## ocean.layer_changed.connect(_on_layer_changed)
## add_child(ocean)
## camera_tool.flash_fired.connect(ocean.spawn_flash_lure)
## [/codeblock]

## Emitted when the diver enters another layer, and once on entering the tree.
signal layer_changed(index: int)
## Emitted when a flash left a lure in a flash-lure layer.
signal flash_lure_spawned(lure: FlashLure)

# Drawn extent of the water and sky (layout only).
const WORLD_HALF_WIDTH := 4000.0
const SKY_HEIGHT := 2000.0
## Meters of water drawn below the deepest layer's start.
const DEEPEST_LAYER_DRAWN_DEPTH := 1000.0

## Injected layer data. Must be set before the node enters the tree.
@export var config: LayersConfig
## The diver whose depth selects the layer. Must be set before the node enters the tree.
var diver: Diver
## Index into [member LayersConfig.layers] of the diver's current layer.
var current_index: int = -1

var _ambient: CanvasModulate


func _ready() -> void:
	z_index = -100 # the water is behind everything
	_ambient = CanvasModulate.new()
	add_child(_ambient)
	_update_layer()


func _physics_process(_delta: float) -> void:
	_update_layer()


## The layer the diver is in.
func get_current_layer() -> LayerData:
	return config.layers[current_index]


## Leaves a [FlashLure] at [param global_point] when the layer at that depth lures
## with flashes; returns it, or null when the layer does not.
func spawn_flash_lure(global_point: Vector2) -> FlashLure:
	var layer: LayerData = config.layers[config.get_layer_index(global_point.y / diver.config.pixels_per_meter)]
	if not layer.flash_lures:
		return null
	var lure := FlashLure.new(config.flash_lure_radius, config.flash_lure_duration, config.flash_light_radius)
	add_sibling(lure)
	lure.global_position = global_point
	flash_lure_spawned.emit(lure)
	return lure


func _update_layer() -> void:
	var depth: float = diver.get_depth()
	_ambient.color = config.get_ambient_color(depth)
	var index: int = config.get_layer_index(depth)
	if index == current_index:
		return
	current_index = index
	diver.vitals.oxygen_drain_multiplier = get_current_layer().oxygen_drain_multiplier
	layer_changed.emit(index)


func _draw() -> void:
	var ppm: float = diver.config.pixels_per_meter
	draw_rect(Rect2(-WORLD_HALF_WIDTH, -SKY_HEIGHT, WORLD_HALF_WIDTH * 2.0, SKY_HEIGHT), config.sky_color)
	var count: int = config.layers.size()
	for i in count:
		var layer: LayerData = config.layers[i]
		var top: float = layer.start_depth * ppm
		if i + 1 == count:
			draw_rect(Rect2(-WORLD_HALF_WIDTH, top, WORLD_HALF_WIDTH * 2.0, DEEPEST_LAYER_DRAWN_DEPTH * ppm), layer.water_color)
			continue
		var next: LayerData = config.layers[i + 1]
		var blend_top: float = maxf(next.start_depth - config.blend_depth, layer.start_depth) * ppm
		var bottom: float = next.start_depth * ppm
		draw_rect(Rect2(-WORLD_HALF_WIDTH, top, WORLD_HALF_WIDTH * 2.0, blend_top - top), layer.water_color)
		draw_polygon(
			PackedVector2Array([Vector2(-WORLD_HALF_WIDTH, blend_top), Vector2(WORLD_HALF_WIDTH, blend_top), Vector2(WORLD_HALF_WIDTH, bottom), Vector2(-WORLD_HALF_WIDTH, bottom)]),
			PackedColorArray([layer.water_color, layer.water_color, next.water_color, next.water_color]))
