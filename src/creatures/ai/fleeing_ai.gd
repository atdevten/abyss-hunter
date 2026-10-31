class_name FleeingAI
extends CreatureAI
## Fleeing AI: runs from the diver and from predators inside [member SpeciesData.aggro_radius],
## the closer the threat the harder; wanders otherwise. A schooling species
## ([member SpeciesData.school_radius] > 0) also pulls toward its schoolmates, and
## while a predator is near the school tightens by
## [member SpeciesData.predator_tighten_multiplier] (lanternfish).
## Sardine and lanternfish. Behaviour names: [code]wander[/code], [code]flee[/code],
## [code]school_tight[/code] (fleeing with the school tightened).
## Implements Story 003 (production/epics/abyss-hunter/story-003-species-ai-blood.md).


func think(delta: float) -> void:
	var species: SpeciesData = creature.species
	var here: Vector2 = creature.global_position
	var push := Vector2.ZERO
	var predator_near := false
	var context: CreatureContext = creature.context
	if context.is_diver_active():
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
	var desired: Vector2 = wander_velocity(delta)
	if push != Vector2.ZERO:
		desired = push.normalized() * species.speed
	var tighten: float = species.predator_tighten_multiplier if predator_near else 1.0
	desired += _school_pull(mates, tighten) * species.speed
	if predator_near and tighten > 1.0 and not mates.is_empty():
		creature.set_behaviour(&"school_tight")
	elif push != Vector2.ZERO:
		creature.set_behaviour(&"flee")
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
