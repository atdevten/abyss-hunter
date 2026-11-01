class_name CreatureContext
extends RefCounted
## World state shared by every creature in a dive: the diver they react to,
## the session's [Encyclopedia] (Story 005: which advantages are unlocked per
## species), and (Story 004) the depth layers and the diver's lamp. Injected into
## each [Creature] by its spawner, so a commit at the boat affects all creatures at once.
## Implements Story 003 (production/epics/abyss-hunter/story-003-species-ai-blood.md)
## and Story 005 (production/epics/abyss-hunter/story-005-encyclopedia.md).
## Story 007: the optional [Population] (food chain) predators read their hunger from.
##
## Usage:
## [codeblock]
## var context := CreatureContext.new(diver)
## creature.context = context
## context.encyclopedia = encyclopedia   # required: creatures read their advantages from it
## context.depth_layers = ocean          # optional: without both, no lamp reactions
## context.lamp = lamp
## [/codeblock]

## The diver creatures flee from or hunt. Predators damage it through [member Diver.vitals].
var diver: Diver
## The session's unlock state. Must be set before creatures enter the tree. An
## UNLOCKED BEHAVIOUR half highlights a predator's warning (and lengthens its display)
## or shows a prey's behaviour hint; an UNLOCKED WEAK_SPOT half marks the weak spot.
var encyclopedia: Encyclopedia
## The ocean's layers; the diver's current layer decides the lamp reaction. Optional.
var depth_layers: DepthLayers
## The diver's lamp. Optional.
var lamp: Lamp
## The food chain (Story 007). Optional: without it creatures register nowhere and
## predators never turn hungry or migrate.
var population: Population


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
