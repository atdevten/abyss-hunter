class_name CreatureContext
extends RefCounted
## World state shared by every creature in a dive: the diver they react to and
## the encyclopedia-knowledge switch. Injected into each [Creature] by its spawner,
## so flipping [member knowledge_enabled] affects all creatures at once.
## Implements Story 003 (production/epics/abyss-hunter/story-003-species-ai-blood.md).
##
## Usage:
## [codeblock]
## var context := CreatureContext.new(diver)
## creature.context = context
## context.knowledge_enabled = true   # Story 005 drives this; here a debug switch
## [/codeblock]

## The diver creatures flee from or hunt. Predators damage it through [member Diver.vitals].
var diver: Diver
## When true the player has the encyclopedia advantages: weak spots are shown,
## a predator's display shows its charge/leave lines and lasts longer.
var knowledge_enabled: bool = false


func _init(dive_diver: Diver) -> void:
	diver = dive_diver


## True when the diver exists and is alive, so it can be fled from or hunted.
func is_diver_active() -> bool:
	return diver != null and not diver.vitals.is_dead
