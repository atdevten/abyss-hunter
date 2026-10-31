class_name PassiveAI
extends CreatureAI
## Passive AI: drifts around its home and ignores the diver and predators.
## Pufferfish and Atolla jelly. Behaviour name: [code]drift[/code].
## Implements Story 003 (production/epics/abyss-hunter/story-003-species-ai-blood.md).


func think(delta: float) -> void:
	creature.set_behaviour(&"drift")
	creature.steer(wander_velocity(delta), delta)
