class_name CreatureContext
extends RefCounted
## World state shared by every creature in a dive: the diver they react to,
## the encyclopedia-knowledge switch, and (Story 004) the depth layers and the
## diver's lamp. Injected into each [Creature] by its spawner,
## so flipping [member knowledge_enabled] affects all creatures at once.
## Implements Story 003 (production/epics/abyss-hunter/story-003-species-ai-blood.md).
##
## Usage:
## [codeblock]
## var context := CreatureContext.new(diver)
## creature.context = context
## context.knowledge_enabled = true   # Story 005 drives this; here a debug switch
## context.depth_layers = ocean          # optional: without both, no lamp reactions
## context.lamp = lamp
## [/codeblock]

## The diver creatures flee from or hunt. Predators damage it through [member Diver.vitals].
var diver: Diver
## When true the player has the encyclopedia advantages: weak spots are shown,
## a predator's display shows its charge/leave lines and lasts longer.
var knowledge_enabled: bool = false
## The ocean's layers; the diver's current layer decides the lamp reaction. Optional.
var depth_layers: DepthLayers
## The diver's lamp. Optional.
var lamp: Lamp


func _init(dive_diver: Diver) -> void:
	diver = dive_diver


## True when the diver exists and is alive, so it can be fled from or hunted.
func is_diver_active() -> bool:
	return diver != null and not diver.vitals.is_dead


## How creatures react to the lamp right now: the diver's layer's reaction while the
## lamp is on and white, NONE when it is off, red, or there is no lamp or layers.
func get_lamp_reaction() -> LayerData.LampReaction:
	if depth_layers == null or lamp == null or not lamp.is_seen_by_creatures():
		return LayerData.LampReaction.NONE
	return depth_layers.get_current_layer().lamp_reaction


## True when the white lamp repels [param creature] where it is now: a REPEL layer,
## a species that does not ignore the lamp, and within the repel radius.
func lamp_repels(creature: Creature) -> bool:
	return get_lamp_reaction() == LayerData.LampReaction.REPEL and not creature.species.ignores_lamp \
		and creature.global_position.distance_to(lamp.global_position) <= depth_layers.config.lamp_repel_radius
