class_name PredatorAI
extends CreatureAI
## Predator AI, a small state machine. Grey reef shark and giant squid.
## [codeblock]
## patrol --diver in aggro_radius--> display (or charge if display_duration is 0)
## patrol --blood lure in its radius--> lured --lure faded--> patrol
## lured  --diver in aggro_radius--> display (or charge)
## display --diver backs off to leave_distance--> leave --leave_time--> patrol
## display --diver pushes in to charge_distance, or display time runs out--> charge
## charge --reaches attack_reach: diver takes damage--> recover --recover_time--> patrol
## charge --charge_max_time passed (miss)--> recover
## [/codeblock]
## The display (snout up, pectoral fins down, back arched) is drawn by the creature
## while [member Creature.display_pose] is set. With encyclopedia knowledge on, the
## display lasts [member SpeciesData.knowledge_display_extra_time] longer.
## Behaviour names reported: [code]patrol, lured, display, charge, recover, leave[/code].
## Implements Story 003 (production/epics/abyss-hunter/story-003-species-ai-blood.md).

enum State { PATROL, LURED, DISPLAY, CHARGE, RECOVER, LEAVE }

const STATE_NAMES: Dictionary[State, StringName] = {
	State.PATROL: &"patrol",
	State.LURED: &"lured",
	State.DISPLAY: &"display",
	State.CHARGE: &"charge",
	State.RECOVER: &"recover",
	State.LEAVE: &"leave",
}

var _state: State = State.PATROL
var _state_time: float = 0.0
## Display length fixed when the display starts, so toggling knowledge mid-display does not jump.
var _display_time: float = 0.0


func _ready() -> void:
	creature.set_behaviour(STATE_NAMES[_state])


func think(delta: float) -> void:
	var species: SpeciesData = creature.species
	var context: CreatureContext = creature.context
	_state_time += delta
	var diver_active: bool = context.is_diver_active()
	var diver_position: Vector2 = context.diver.global_position if context.diver else creature.global_position
	var distance: float = creature.global_position.distance_to(diver_position)
	match _state:
		State.PATROL, State.LURED:
			if diver_active and distance <= species.aggro_radius:
				_enter(State.DISPLAY if species.display_duration > 0.0 else State.CHARGE)
				return
			var lure: BloodLure = _nearest_lure()
			if lure == null:
				_enter(State.PATROL)
				creature.steer(wander_velocity(delta), delta)
				return
			_enter(State.LURED)
			var to_lure: Vector2 = lure.global_position - creature.global_position
			var arrive: float = clampf(to_lure.length() / species.lure_arrive_distance, 0.0, 1.0)
			creature.steer(to_lure.normalized() * species.speed * arrive, delta)
		State.DISPLAY:
			creature.face_toward(diver_position)
			creature.steer(Vector2.ZERO, delta)
			if not diver_active:
				_enter(State.PATROL)
			elif distance >= species.leave_distance:
				_enter(State.LEAVE)
			elif distance <= species.charge_distance or _state_time >= _display_time:
				_enter(State.CHARGE)
		State.CHARGE:
			creature.face_toward(diver_position)
			creature.velocity = creature.global_position.direction_to(diver_position) * species.speed * species.charge_speed_multiplier
			if diver_active and distance <= species.attack_reach:
				context.diver.vitals.take_damage(species.damage)
				creature.struck_diver.emit(creature, species.damage)
				_enter(State.RECOVER)
			elif not diver_active or _state_time >= species.charge_max_time:
				_enter(State.RECOVER)
		State.RECOVER, State.LEAVE:
			creature.steer(diver_position.direction_to(creature.global_position) * species.speed, delta)
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
		if creature.context.knowledge_enabled:
			_display_time += creature.species.knowledge_display_extra_time
	creature.set_behaviour(STATE_NAMES[state])


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
