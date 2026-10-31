class_name DiverConfig
extends Resource
## Tuning data for the diver: movement, bar sizes, oxygen drain, surface refill, lamp.
## The per-layer depths and oxygen drain multipliers live in [LayersConfig] (Story 004).
##
## Usage:
## [codeblock]
## var config: DiverConfig = load("res://src/diver/diver_config.tres")
## var max_speed: float = config.swim_speed
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
## Base oxygen lost per second at multiplier 1.0 (the layer's multiplier, see [LayerData]).
@export var oxygen_drain_per_second: float = 1.5

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

@export_group("Lamp")
## Radius of the lamp's light in pixels.
@export var lamp_radius: float = 260.0
## Brightness of the lamp's light.
@export var lamp_energy: float = 1.2
@export var lamp_white_color: Color = Color(1.0, 0.97, 0.88)
## Color of the red lamp (Story 006 upgrade): lights the way, unseen by creatures.
@export var lamp_red_color: Color = Color(1.0, 0.15, 0.1)

