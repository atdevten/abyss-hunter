class_name Population
extends RefCounted
## The minimal food chain (Story 007): an abstract prey stock per depth layer.
## Killing a prey creature (any non-predator) takes one from the stock of the layer
## it died in; docking at the boat ([method recover]) adds
## [member LayerPopulationData.recovery_per_dock] back, up to the starting stock. The
## stock is not the number of fish swimming: the scene does not respawn fish, the
## stock is what the layer's predators "see".
## Each layer's state is derived from its stock: NORMAL, HUNGRY (below the aggression
## threshold: its predators are faster with a larger aggro radius) or MIGRATING (below
## the lower migration threshold: its predators also hunt one layer shallower, and
## return home once the stock is back at the threshold). Predators read this through
## [member CreatureContext.population]; their home layer is the layer they spawned in.
## Not a simulation: prey never breeds or moves between layers.
## Implements Story 007 (production/epics/abyss-hunter/story-007-food-chain.md).
##
## Usage:
## [codeblock]
## var population := Population.new(ecosystem_config, layers_config, pixels_per_meter)
## context.population = population      # creatures register themselves on spawn
## boat.docked.connect(population.recover.unbind(3))
## population.layer_state_changed.connect(func(i: int, s: Population.State) -> void: print(i, s))
## [/codeblock]

enum State { NORMAL, HUNGRY, MIGRATING }

## Emitted when a layer's prey stock changes by [param change] (kill, recovery, debug).
signal prey_count_changed(layer_index: int, count: int, change: int)
## Emitted when a layer's derived state changes.
signal layer_state_changed(layer_index: int, state: State)

var config: EcosystemConfig
var layers: LayersConfig
var pixels_per_meter: float
## Current prey stock per layer, shallow to deep.
var counts: Array[int] = []

var _states: Array[State] = []


func _init(ecosystem_config: EcosystemConfig, layers_config: LayersConfig, meters_to_pixels: float) -> void:
	config = ecosystem_config
	layers = layers_config
	pixels_per_meter = meters_to_pixels
	for data: LayerPopulationData in config.layers:
		counts.append(data.starting_prey)
		_states.append(State.NORMAL)
	for i in counts.size():
		_states[i] = get_state(i)


## Hooks [param creature]'s death into the stock: called by every creature on spawn.
## A dead creature is unregistered by the signal itself (it frees right after).
func register(creature: Creature) -> void:
	creature.died.connect(record_kill)


## Takes one prey from the stock of the layer [param creature] died in. Predators do
## not count as prey.
func record_kill(creature: Creature) -> void:
	if creature.species.ai_kind != SpeciesData.AiKind.PREDATOR:
		var index: int = get_layer_at(creature.global_position)
		set_count(index, counts[index] - 1)


## Diver docked at the boat: every layer recovers its recovery amount, never past
## its starting stock (a stock already above it is left alone).
func recover() -> void:
	for i in counts.size():
		var data: LayerPopulationData = config.layers[i]
		set_count(i, maxi(counts[i], mini(counts[i] + data.recovery_per_dock, data.starting_prey)))


## Sets layer [param index]'s stock (clamped at 0), emitting the change signals.
func set_count(index: int, count: int) -> void:
	count = maxi(count, 0)
	if count == counts[index]:
		return
	var change: int = count - counts[index]
	counts[index] = count
	prey_count_changed.emit(index, count, change)
	var state: State = get_state(index)
	if state != _states[index]:
		_states[index] = state
		layer_state_changed.emit(index, state)


## State of layer [param index], derived from its stock and thresholds.
func get_state(index: int) -> State:
	var data: LayerPopulationData = config.layers[index]
	if counts[index] < data.migration_threshold:
		return State.MIGRATING
	if counts[index] < data.aggression_threshold:
		return State.HUNGRY
	return State.NORMAL


## Layer the predators of [param home_layer] hunt in: one shallower while it is
## MIGRATING (the shallowest layer has nowhere to go), else their home.
func get_hunt_layer(home_layer: int) -> int:
	return maxi(home_layer - 1, 0) if get_state(home_layer) == State.MIGRATING else home_layer


## Speed multiplier for the predators of [param home_layer] (1 while it is NORMAL).
func get_speed_multiplier(home_layer: int) -> float:
	return 1.0 if get_state(home_layer) == State.NORMAL else config.layers[home_layer].aggression_speed_multiplier


## Aggro radius multiplier for the predators of [param home_layer] (1 while NORMAL).
func get_aggro_multiplier(home_layer: int) -> float:
	return 1.0 if get_state(home_layer) == State.NORMAL else config.layers[home_layer].aggression_aggro_multiplier


## Index of the layer containing [param global_point] (pixels; y 0 is the surface).
func get_layer_at(global_point: Vector2) -> int:
	return layers.get_layer_index(global_point.y / pixels_per_meter)


## Patrol center of a predator whose home patrol center is [param home_anchor] while
## it hunts in [param hunt_layer]: the anchor itself at home, else straight above it,
## [member EcosystemConfig.migration_depth_above_boundary] above the bottom of the
## shallower layer.
func get_hunt_position(home_anchor: Vector2, hunt_layer: int) -> Vector2:
	if hunt_layer == get_layer_at(home_anchor):
		return home_anchor
	var bottom: float = layers.layers[hunt_layer + 1].start_depth
	return Vector2(home_anchor.x, (bottom - config.migration_depth_above_boundary) * pixels_per_meter)


## One-line readout for tuning: "Prey bright 20/20 NORMAL, dim 1/12 MIGRATING, ...".
func describe() -> String:
	var parts: PackedStringArray = []
	for i in counts.size():
		parts.append("%s %d/%d %s" % [layers.layers[i].display_name, counts[i], config.layers[i].starting_prey, State.keys()[get_state(i)]])
	return "Prey " + ", ".join(parts)
