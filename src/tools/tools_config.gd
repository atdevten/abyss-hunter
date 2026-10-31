class_name ToolsConfig
extends Resource
## Tuning data for the diver's tools: harpoon gun and camera.
## Implements Story 002 (production/epics/abyss-hunter/story-002-harpoon-camera-flash.md).
##
## Usage:
## [codeblock]
## var config: ToolsConfig = load("res://src/tools/tools_config.tres")
## var gun := HarpoonGun.new()
## gun.config = config
## [/codeblock]

@export_group("Harpoon")
## Harpoon flight speed in pixels per second.
@export var harpoon_speed: float = 900.0
## Distance in pixels after which a harpoon that hit nothing is lost.
@export var harpoon_max_range: float = 480.0
## Seconds between shots.
@export var harpoon_reload_time: float = 1.0
## Damage dealt to a creature on hit.
@export var harpoon_damage: float = 25.0
## How deep past the entry point the tip strikes, in pixels. The weak spot check uses
## this strike point, so a weak spot inside the body is reachable.
@export var harpoon_penetration: float = 24.0
## Drawn length of the harpoon shaft in pixels (visual only).
@export var harpoon_length: float = 24.0

@export_group("Camera")
## Seconds between photos.
@export var camera_cooldown: float = 0.75
## Seconds the flash stays visible while fading out.
@export var flash_duration: float = 0.3
## Width and height of the photo frame in pixels, centered on the aim point.
@export var photo_frame_size: Vector2 = Vector2(160.0, 120.0)
