class_name GlowLight
extends PointLight2D
## Round 2D light with a soft radial falloff, sized in pixels. Used for the diver's
## lamp, creature bioluminescence and the camera flash. Works under the Compatibility
## renderer (checked on Godot 4.7.2 with CanvasModulate, Story 004).
## Implements Story 004 (production/epics/abyss-hunter/story-004-depth-layers-lamp.md).
##
## Usage:
## [codeblock]
## var glow := GlowLight.new(24.0, Color(0.3, 0.8, 1.0), 1.2)
## creature.add_child(glow)
## [/codeblock]

## Size in pixels of the shared falloff texture.
const TEXTURE_SIZE := 128

static var _shared_texture: GradientTexture2D


func _init(radius: float = 64.0, light_color: Color = Color.WHITE, light_energy: float = 1.0) -> void:
	if _shared_texture == null:
		_shared_texture = GradientTexture2D.new()
		_shared_texture.width = TEXTURE_SIZE
		_shared_texture.height = TEXTURE_SIZE
		_shared_texture.fill = GradientTexture2D.FILL_RADIAL
		_shared_texture.fill_from = Vector2(0.5, 0.5)
		_shared_texture.fill_to = Vector2(1.0, 0.5)
		var gradient := Gradient.new()
		gradient.set_color(0, Color.WHITE)
		gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
		_shared_texture.gradient = gradient
	texture = _shared_texture
	# Story 009 / art bible §8: the project default filter is Nearest (pixel art); the
	# falloff gradient must stay Linear. Measured on 4.7.2 Compatibility: Light2D
	# textures already sample Linear whatever the project default or this property
	# (identical frames with and without it), so this states the intent explicitly.
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	set_radius(radius)
	color = light_color
	energy = light_energy


## Sets the lit radius in pixels.
func set_radius(radius: float) -> void:
	texture_scale = radius * 2.0 / TEXTURE_SIZE
