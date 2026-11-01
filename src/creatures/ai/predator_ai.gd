class_name PredatorAI
extends CreatureAI
## Predator AI, a small state machine. Grey reef shark and giant squid.
## [codeblock]
## patrol --diver in aggro_radius--> display (or charge if display_duration is 0)
## patrol --blood lure in its radius--> lured --lure faded--> patrol
## lured  --diver in aggro_radius--> display (or charge)
## patrol --lamp-drawn fish near the lamp, in prey_follow_radius--> follow_prey (Story 004)
## follow_prey --diver in aggro_radius--> display (or charge); --lure--> lured; --no fish--> patrol
## patrol, lured, follow_prey --white lamp repels it (REPEL layer)--> lamp_scared --leave_time--> patrol
## display --diver backs off to leave_distance--> leave --leave_time--> patrol
## display --diver pushes in to charge_distance, or display time runs out--> charge
## charge --reaches attack_reach: diver takes damage--> recover --recover_time--> patrol
## charge --charge_max_time passed (miss)--> recover
## patrol --food chain moved its hunt layer (Story 007)--> migrate (up a layer) or
##        return_home --within wander_radius of the new patrol center--> patrol
## migrate, return_home: diver, lamp and lures interrupt them as they do patrol
## [/codeblock]
## The display (snout up, pectoral fins down, back arched) is drawn by the creature
## while [member Creature.display_pose] is set. With the species' warning half
## unlocked in the [Encyclopedia], the display lasts
## [member SpeciesData.knowledge_display_extra_time] longer.
## Flash lures ([FlashLure], Story 004) are blood lures to this AI.
## Behaviour names reported: [code]patrol, lured, display, charge, recover, leave,
## follow_prey, lamp_scared, migrate, return_home[/code].
## Story 007 food chain, with [member CreatureContext.population] set: the home layer
## is the layer the predator spawned in; while that layer is HUNGRY or MIGRATING
## its speed and aggro radius are multiplied, and while MIGRATING its patrol center
## ([member Creature.home_position]) moves up into the next shallower layer (and
## back home once the stock recovers), travelling there at full speed. The leave
## distance scales with the aggro radius, so a display started at the larger radius
## does not end at once in leave.
## Implements Story 003 (production/epics/abyss-hunter/story-003-species-ai-blood.md).

enum State { PATROL, LURED, DISPLAY, CHARGE, RECOVER, LEAVE, FOLLOW_PREY, LAMP_SCARED, MIGRATE, RETURN_HOME }

const STATE_NAMES: Dictionary[State, StringName] = {
	State.PATROL: &"patrol",
	State.LURED: &"lured",
	State.DISPLAY: &"display",
	State.CHARGE: &"charge",
	State.RECOVER: &"recover",
	State.LEAVE: &"leave",
	State.FOLLOW_PREY: &"follow_prey",
	State.LAMP_SCARED: &"lamp_scared",
	State.MIGRATE: &"migrate",
	State.RETURN_HOME: &"return_home",
}

var _state: State = State.PATROL
var _state_time: float = 0.0
## Display length fixed when the display starts, so a commit mid-display does not jump.
var _display_time: float = 0.0
# Story 007: spawn patrol center and its layer, the layer hunted in now, and
# whether it is still travelling to a patrol center the food chain moved.
var _home_anchor: Vector2
var _home_layer: int = 0
var _hunt_layer: int = 0
var _travelling: bool = false


func _ready() -> void:
	creature.set_behaviour(STATE_NAMES[_state])
	_home_anchor = creature.home_position
	if creature.context.population:
		_home_layer = creature.context.population.get_layer_at(_home_anchor)
		_hunt_layer = _home_layer


func think(delta: float) -> void:
	var species: SpeciesData = creature.species
	var context: CreatureContext = creature.context
	_state_time += delta
	var diver_active: bool = context.is_diver_active()
	var diver_position: Vector2 = context.diver.global_position if context.diver else creature.global_position
	var distance: float = creature.global_position.distance_to(diver_position)
	var speed: float = species.speed
	var aggro_scale: float = 1.0
	var population: Population = context.population
	if population:
		speed *= population.get_speed_multiplier(_home_layer)
		aggro_scale = population.get_aggro_multiplier(_home_layer)
		var hunt_layer: int = population.get_hunt_layer(_home_layer)
		if hunt_layer != _hunt_layer:
			_hunt_layer = hunt_layer
			creature.home_position = population.get_hunt_position(_home_anchor, hunt_layer)
			_travelling = true
	match _state:
		State.PATROL, State.LURED, State.FOLLOW_PREY, State.MIGRATE, State.RETURN_HOME:
			if context.lamp_repels(creature):
				_enter(State.LAMP_SCARED)
				return
			if diver_active and distance <= species.aggro_radius * aggro_scale:
				_enter(State.DISPLAY if species.display_duration > 0.0 else State.CHARGE)
				return
			var target: Node2D = _nearest_lure()
			var next_state: State = State.LURED
			if target == null:
				target = _nearest_lamp_prey()
				next_state = State.FOLLOW_PREY
			if target == null:
				if _travelling and creature.global_position.distance_to(creature.home_position) > species.wander_radius:
					_enter(State.MIGRATE if _hunt_layer != _home_layer else State.RETURN_HOME)
					creature.steer(creature.global_position.direction_to(creature.home_position) * speed, delta)
					return
				_travelling = false
				_enter(State.PATROL)
				creature.steer(wander_velocity(delta, speed / species.speed), delta)
				return
			_enter(next_state)
			var to_target: Vector2 = target.global_position - creature.global_position
			var arrive: float = clampf(to_target.length() / species.lure_arrive_distance, 0.0, 1.0)
			creature.steer(to_target.normalized() * speed * arrive, delta)
		State.DISPLAY:
			creature.face_toward(diver_position)
			creature.steer(Vector2.ZERO, delta)
			if not diver_active:
				_enter(State.PATROL)
			elif distance >= species.leave_distance * aggro_scale:
				_enter(State.LEAVE)
			elif distance <= species.charge_distance or _state_time >= _display_time:
				_enter(State.CHARGE)
		State.CHARGE:
			creature.face_toward(diver_position)
			creature.velocity = creature.global_position.direction_to(diver_position) * speed * species.charge_speed_multiplier
			if diver_active and distance <= species.attack_reach:
				context.diver.vitals.take_damage(species.damage)
				creature.struck_diver.emit(creature, species.damage)
				_enter(State.RECOVER)
			elif not diver_active or _state_time >= species.charge_max_time:
				_enter(State.RECOVER)
		State.RECOVER, State.LEAVE, State.LAMP_SCARED:
			creature.steer(diver_position.direction_to(creature.global_position) * speed, delta)
			if _state_time >= (species.recover_time if _state == State.RECOVER else species.leave_time):
				_enter(State.PATROL)


func _enter(state: State) -> void:
	if state == _state:
		return
	_state = state
	_state_time = 0.0
	creature.display_pose = state == State.DISPLAY
	if state == State.DISPLAY:
		_display_time = creature.species.display_duration
		if creature.context.encyclopedia.is_unlocked(creature.species_id, Encyclopedia.Half.BEHAVIOUR):
			_display_time += creature.species.knowledge_display_extra_time
	creature.set_behaviour(STATE_NAMES[state])


## In an ATTRACT layer, the nearest lamp-drawn creature around the lamp within
## [member LayersConfig.prey_follow_radius]; null otherwise.
func _nearest_lamp_prey() -> Creature:
	var context: CreatureContext = creature.context
	if context.get_lamp_reaction() != LayerData.LampReaction.ATTRACT:
		return null
	var config: LayersConfig = context.depth_layers.config
	var nearest: Creature = null
	var best: float = config.prey_follow_radius
	for node: Node in get_tree().get_nodes_in_group(Creature.GROUP):
		var prey := node as Creature
		var distance: float = creature.global_position.distance_to(prey.global_position)
		if prey.species.drawn_to_lamp and distance <= best and prey.global_position.distance_to(context.lamp.global_position) <= config.lamp_attract_radius:
			nearest = prey
			best = distance
	return nearest


func _nearest_lure() -> BloodLure:
	var nearest: BloodLure = null
	var best: float = INF
	for node: Node in get_tree().get_nodes_in_group(BloodLure.GROUP):
		var lure := node as BloodLure
		var distance: float = creature.global_position.distance_to(lure.global_position)
		if lure.attracts(creature.global_position) and distance < best:
			nearest = lure
			best = distance
	return nearest
