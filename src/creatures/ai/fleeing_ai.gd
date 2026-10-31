class_name FleeingAI
extends CreatureAI
## Fleeing AI: runs from the diver and from predators inside [member SpeciesData.aggro_radius],
## the closer the threat the harder; wanders otherwise. A schooling species
## ([member SpeciesData.school_radius] > 0) also pulls toward its schoolmates, and
## while a predator is near the school tightens by
## [member SpeciesData.predator_tighten_multiplier] (lanternfish).
## Sardine and lanternfish. Behaviour names: [code]wander[/code], [code]flee[/code],
## [code]school_tight[/code] (fleeing with the school tightened).
## Story 004 lamp reactions: in an ATTRACT layer a [member SpeciesData.drawn_to_lamp]
## species within [member LayersConfig.lamp_attract_radius] stops fearing the diver and
## hovers at [member LayersConfig.lamp_hold_distance] from the lamp ([code]lamp_drawn[/code]);
## predators still scare it. In a REPEL layer it flees the lamp ([code]lamp_scared[/code]).
## Implements Story 003 (production/epics/abyss-hunter/story-003-species-ai-blood.md).


func think(delta: float) -> void:
	var species: SpeciesData = creature.species
	var here: Vector2 = creature.global_position
	var push := Vector2.ZERO
	var predator_near := false
	var context: CreatureContext = creature.context
	var lamp_pull := Vector2.ZERO
	var drawn := false
	var scared: bool = context.lamp_repels(creature)
	if scared:
		push += _away_from(context.lamp.global_position, here, context.depth_layers.config.lamp_repel_radius)
	elif species.drawn_to_lamp and context.get_lamp_reaction() == LayerData.LampReaction.ATTRACT:
		var config: LayersConfig = context.depth_layers.config
		var to_lamp: Vector2 = context.lamp.global_position - here
		drawn = to_lamp.length() <= config.lamp_attract_radius
		lamp_pull = to_lamp.normalized() * clampf((to_lamp.length() - config.lamp_hold_distance) / config.lamp_hold_distance, -1.0, 1.0)
	if context.is_diver_active() and not drawn:
		push += _away_from(context.diver.global_position, here, species.aggro_radius)
	var mates: Array[Creature] = []
	for node: Node in get_tree().get_nodes_in_group(Creature.GROUP):
		var other := node as Creature
		if other == creature:
			continue
		if other.species.ai_kind == SpeciesData.AiKind.PREDATOR:
			var away: Vector2 = _away_from(other.global_position, here, species.aggro_radius)
			predator_near = predator_near or away != Vector2.ZERO
			push += away
		elif species.school_radius > 0.0 and other.species.species_id == species.species_id and here.distance_to(other.global_position) <= species.school_radius:
			mates.append(other)
	var desired: Vector2 = lamp_pull * species.speed if drawn else wander_velocity(delta)
	if push != Vector2.ZERO:
		desired = push.normalized() * species.speed
	var tighten: float = species.predator_tighten_multiplier if predator_near else 1.0
	desired += _school_pull(mates, tighten) * species.speed
	if predator_near and tighten > 1.0 and not mates.is_empty():
		creature.set_behaviour(&"school_tight")
	elif scared:
		creature.set_behaviour(&"lamp_scared")
	elif push != Vector2.ZERO:
		creature.set_behaviour(&"flee")
	elif drawn:
		creature.set_behaviour(&"lamp_drawn")
	else:
		creature.set_behaviour(&"wander")
	creature.steer(desired.limit_length(species.speed), delta)


## Unit-scaled push away from [param threat], 0 at the radius edge, 1 on top of it.
func _away_from(threat: Vector2, here: Vector2, radius: float) -> Vector2:
	var distance: float = here.distance_to(threat)
	if distance > radius:
		return Vector2.ZERO
	return threat.direction_to(here) * (1.0 - distance / radius)


## Cohesion toward the mates' center plus separation from mates that are too close.
func _school_pull(mates: Array[Creature], tighten: float) -> Vector2:
	if mates.is_empty():
		return Vector2.ZERO
	var species: SpeciesData = creature.species
	var here: Vector2 = creature.global_position
	var center := Vector2.ZERO
	var separation := Vector2.ZERO
	var keep_apart: float = species.separation_distance / tighten
	for mate in mates:
		center += mate.global_position
		var distance: float = here.distance_to(mate.global_position)
		if distance < keep_apart:
			separation += mate.global_position.direction_to(here) * (1.0 - distance / keep_apart)
	center /= mates.size()
	var cohesion: Vector2 = (center - here) / species.school_radius * species.cohesion_weight * tighten
	return cohesion + separation
