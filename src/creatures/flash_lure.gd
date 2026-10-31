class_name FlashLure
extends BloodLure
## The lure a flash of light leaves in a dark layer (a camera flash, or an Atolla
## jelly's hit flash): predators within [member BloodLure.radius] swim to it until it
## fades, exactly as to blood (same [constant BloodLure.GROUP]). Lights the water
## around it with a [GlowLight] that fades with the lure. Spawned by
## [method DepthLayers.spawn_flash_lure].
## Implements Story 004 (production/epics/abyss-hunter/story-004-depth-layers-lamp.md).

## Light energy of the flash when fresh (visual only).
const FLASH_ENERGY := 2.5
const FLASH_COLOR := Color(0.85, 0.95, 1.0)

var _light: GlowLight


func _init(lure_radius: float, lure_duration: float, light_radius: float) -> void:
	super(lure_radius, lure_duration)
	_light = GlowLight.new(light_radius, FLASH_COLOR, FLASH_ENERGY)
	add_child(_light)


func _physics_process(delta: float) -> void:
	super(delta)
	var strength: float = clampf(_time_left / duration, 0.0, 1.0)
	_light.energy = FLASH_ENERGY * strength * strength * strength


func _draw() -> void:
	var strength: float = clampf(_time_left / duration, 0.0, 1.0)
	draw_circle(Vector2.ZERO, radius, Color(0.8, 0.9, 1.0, 0.3 * strength), false, 1.0)
