class_name DiverVitals
extends RefCounted
## Oxygen and health of the diver. No scene dependency; the config is injected.
##
## Usage:
## [codeblock]
## var vitals := DiverVitals.new(config)
## vitals.diver_died.connect(func(cause: DiverVitals.Cause) -> void: print(cause))
## vitals.tick(delta, depth_meters)   # call every physics frame
## vitals.take_damage(10.0)           # called by other systems
## [/codeblock]
## Not thread-safe; call from the main thread only.

enum Cause { OXYGEN, HEALTH }

## Emitted exactly once per dive when oxygen or health reaches 0.
signal diver_died(cause: Cause)
signal oxygen_changed(current: float, maximum: float)
signal health_changed(current: float, maximum: float)

var oxygen: float
var health: float
var is_dead: bool = false

## Tuning data injected at construction. Read-only by convention.
var config: DiverConfig


func _init(vitals_config: DiverConfig) -> void:
	config = vitals_config
	start_dive()


## Refills both bars and clears the dead state. Called at the start of each dive.
func start_dive() -> void:
	is_dead = false
	oxygen = config.max_oxygen
	health = config.max_health
	oxygen_changed.emit(oxygen, config.max_oxygen)
	health_changed.emit(health, config.max_health)


## Advances vitals by [param delta] seconds at [param depth] meters.
## At the surface both bars refill; below it oxygen drains by the layer multiplier.
func tick(delta: float, depth: float) -> void:
	if is_dead:
		return
	if depth <= config.surface_depth:
		oxygen = minf(oxygen + config.surface_oxygen_refill_per_second * delta, config.max_oxygen)
		health = minf(health + config.surface_health_refill_per_second * delta, config.max_health)
		oxygen_changed.emit(oxygen, config.max_oxygen)
		health_changed.emit(health, config.max_health)
		return
	var multiplier: float = config.oxygen_drain_multipliers[config.get_layer_index(depth)]
	oxygen = maxf(oxygen - config.oxygen_drain_per_second * multiplier * delta, 0.0)
	oxygen_changed.emit(oxygen, config.max_oxygen)
	if oxygen <= 0.0:
		_die(Cause.OXYGEN)


## Reduces health by [param amount]. Ignored once dead.
func take_damage(amount: float) -> void:
	if is_dead:
		return
	health = maxf(health - amount, 0.0)
	health_changed.emit(health, config.max_health)
	if health <= 0.0:
		_die(Cause.HEALTH)


func _die(cause: Cause) -> void:
	is_dead = true
	diver_died.emit(cause)
