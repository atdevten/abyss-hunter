class_name PassiveAI
extends CreatureAI
## Passive AI: drifts around its home and ignores the diver and predators.
## Pufferfish and Atolla jelly. Behaviour name: [code]drift[/code].
## Story 004: swims away from a repelling white lamp ([code]lamp_scared[/code]) unless
## the species ignores the lamp (Atolla).
## Implements Story 003 (production/epics/abyss-hunter/story-003-species-ai-blood.md).


func think(delta: float) -> void:
	var context: CreatureContext = creature.context
	if context.lamp_repels(creature):
		creature.set_behaviour(&"lamp_scared")
		creature.steer(context.lamp.global_position.direction_to(creature.global_position) * creature.species.speed, delta)
		return
	creature.set_behaviour(&"drift")
	creature.steer(wander_velocity(delta), delta)
