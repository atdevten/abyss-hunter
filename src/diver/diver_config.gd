class_name DiverConfig
extends Resource
## Tuning data for the diver: movement, bar sizes, oxygen drain per layer, surface refill.
##
## Usage:
## [codeblock]
## var config: DiverConfig = load("res://src/diver/diver_config.tres")
## var multiplier: float = config.oxygen_drain_multipliers[config.get_layer_index(80.0)]
## [/codeblock]

@export_group("Swimming")
## Maximum swim speed in pixels per second.
@export var swim_speed: float = 220.0
## Acceleration from input in pixels per second squared.
@export var swim_acceleration: float = 600.0
## Water drag: fraction of velocity lost per second (0 = none).
@export var water_drag: float = 2.0

@export_group("Vitals")
@export var max_oxygen: float = 100.0
@export var max_health: float = 100.0
## Base oxygen lost per second at multiplier 1.0.
@export var oxygen_drain_per_second: float = 1.5
## Depth (meters) at which each layer begins; ascending, first entry is 0.
@export var layer_start_depths: PackedFloat32Array = PackedFloat32Array([0.0, 50.0, 150.0, 300.0])
## Oxygen drain multiplier per layer; same length as layer_start_depths.
@export var oxygen_drain_multipliers: PackedFloat32Array = PackedFloat32Array([1.0, 1.5, 2.5, 4.0])

@export_group("Surface")
## Depth (meters) at or above which the diver counts as at the surface/boat.
@export var surface_depth: float = 1.0
## Oxygen restored per second at the surface.
@export var surface_oxygen_refill_per_second: float = 60.0
## Health restored per second at the surface.
@export var surface_health_refill_per_second: float = 30.0

@export_group("World")
## Pixels per meter, used to convert world y to depth.
@export var pixels_per_meter: float = 16.0


## Returns the index of the layer containing [param depth] (meters).
func get_layer_index(depth: float) -> int:
	var index: int = 0
	for i in layer_start_depths.size():
		if depth >= layer_start_depths[i]:
			index = i
	return index
