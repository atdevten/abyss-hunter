class_name LayerData
extends Resource
## Tuning data for one depth layer of the ocean: where it starts, how much light
## reaches it, how the diver's lamp and camera flash affect creatures there, and how
## fast oxygen drains in it. Listed shallow to deep in [member LayersConfig.layers].
## Implements Story 004 (production/epics/abyss-hunter/story-004-depth-layers-lamp.md).

## How creatures in this layer react to a white lamp that is on.
## NONE: they ignore it. ATTRACT: species with [member SpeciesData.drawn_to_lamp]
## gather at the lamp and predators follow them. REPEL: every species without
## [member SpeciesData.ignores_lamp] moves away from it.
enum LampReaction { NONE, ATTRACT, REPEL }

## Name shown in logs and, later, the HUD.
@export var display_name: String = ""
## Depth in meters at which this layer begins. The first layer starts at 0.
@export var start_depth: float = 0.0
## Oxygen drain multiplier while the diver is in this layer (Story 001 vitals).
@export var oxygen_drain_multiplier: float = 1.0
## Ambient light: every world sprite is multiplied by this (CanvasModulate). Its
## brightness is the layer's visibility; lowering red before green and blue makes
## red fade first and the scene shift toward blue.
@export var ambient_color: Color = Color.WHITE
## Water background color of the layer (before the ambient light is applied).
@export var water_color: Color = Color(0.2, 0.5, 0.8)
## Creature reaction to the white lamp in this layer.
@export var lamp_reaction: LampReaction = LampReaction.NONE
## When true a camera flash here leaves a [FlashLure] that draws predators.
@export var flash_lures: bool = false
