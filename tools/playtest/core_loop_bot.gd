extends SceneTree
## Scripted playtest of the core loop. Loads the main scene (src/diver/dive_test.tscn),
## plays it with real keyboard events (WASD to swim, 1-3 / Space in the shop) and
## direct tool calls (aiming needs a mouse, which a headless run has not), and prints
## one PASS / FAIL line per check plus a summary. Exit code 1 when any check fails.
##
## Run from the project root:
##   godot --headless --path . --fixed-fps 60 -s res://tools/playtest/core_loop_bot.gd
## A windowed run (drop --headless) shows the bot playing.

const PIXELS_PER_METER := 16.0
const FRAME := 1.0 / 60.0
## Fixed seed for the global random generator (creature wander targets use randf()),
## so every run plays the same game and a FAIL is reproducible.
const BOT_SEED := 6 # covers every check (no skips); --seed=<n> tries others

var _scene: Node
var _diver: Diver
var _gun: HarpoonGun
var _camera: CameraTool
var _boat: Boat
var _run: RunState
var _encyclopedia: Encyclopedia
var _population: Population

var _passed := 0
var _failed := 0
var _skipped := 0
var _docks := 0
var _respawns := 0
var _bites := 0
var _highest_creature_top := INF
var _highest_creature := ""


func _initialize() -> void:
	var run_seed: int = BOT_SEED
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--seed="):
			run_seed = arg.trim_prefix("--seed=").to_int()
	print("PLAYTEST SEED %d" % run_seed)
	seed(run_seed)
	_scene = load("res://src/diver/dive_test.tscn").instantiate()
	root.add_child(_scene)
	await physics_frame
	_diver = _scene.get("_diver")
	_gun = _scene.get("_gun")
	_camera = _scene.get("_camera_tool")
	_boat = _scene.get("_boat")
	_run = _scene.get("_run")
	_encyclopedia = _scene.get("_encyclopedia")
	_population = _scene.get("_population")
	_boat.docked.connect(func(_f: int, _e: int, _h: int) -> void: _docks += 1)
	_boat.respawned.connect(func(_c: DiverVitals.Cause, _f: int, _h: int) -> void: _respawns += 1)
	physics_frame.connect(_watch_creatures)

	await _play()
	_check(_highest_creature_top >= 0.0, "creatures never left the water",
		"highest body top y=%.1f px (%s)" % [_highest_creature_top, _highest_creature])
	print("PLAYTEST SUMMARY: %d passed, %d failed, %d skipped" % [_passed, _failed, _skipped])
	quit(1 if _failed > 0 else 0)


func _play() -> void:
	# 1. Start of the run.
	_check(_boat.state == Boat.State.AT_BOAT and _diver.get_depth() <= 1.0, "start on the boat at the surface",
		"depth %.1f m, boat state %s" % [_diver.get_depth(), Boat.State.keys()[_boat.state]])
	_check(is_equal_approx(_diver.vitals.oxygen, _diver.config.max_oxygen) and _run.money == 0,
		"start with a full tank and no money", "oxygen %.0f/%.0f, money $%d" % [_diver.vitals.oxygen, _diver.config.max_oxygen, _run.money])

	# 2. The surface holds the diver in.
	await _hold([KEY_W], 0.5)
	_check(_diver.position.y >= 0.0, "cannot swim above the surface", "y=%.1f px" % _diver.position.y)

	# 3. Swim down: a dive starts and oxygen drains.
	var oxygen_before: float = _diver.vitals.oxygen
	await _hold([KEY_S], 1.5)
	_check(_diver.get_depth() > 10.0 and _boat.state == Boat.State.DIVING, "S swims down and starts a dive",
		"depth %.1f m, boat state %s" % [_diver.get_depth(), Boat.State.keys()[_boat.state]])
	_check(_diver.vitals.oxygen < oxygen_before, "oxygen drains while diving",
		"%.1f -> %.1f" % [oxygen_before, _diver.vitals.oxygen])

	# 4. Photo, then kill, the pufferfish.
	var puffer: Creature = _find_species(&"pufferfish")
	_camera.take_photo(puffer.global_position)
	_check(_encyclopedia.get_state(&"pufferfish", Encyclopedia.Half.BEHAVIOUR) == Encyclopedia.State.PENDING,
		"a photo makes the pufferfish behaviour half pending", "")
	var bright_prey_before: int = _population.counts[0]
	var killed: bool = await _hunt(puffer, 8.0)
	_check(killed, "the harpoon kills the pufferfish", "")
	# Blood can lure the shark into the line of fire, so other fish may be caught too.
	_check(_run.cargo.any(func(s: SpeciesData) -> bool: return s.species_id == &"pufferfish"),
		"the kill goes into cargo", "cargo %d fish" % _run.cargo.size())
	_check(_encyclopedia.get_state(&"pufferfish", Encyclopedia.Half.WEAK_SPOT) == Encyclopedia.State.PENDING,
		"the kill makes the weak-spot half pending", "")
	_check(_population.counts[0] == bright_prey_before - 1, "the kill lowers the bright-layer prey",
		"%d -> %d" % [bright_prey_before, _population.counts[0]])

	# 5. Swim back and dock: sell, commit, refill, shop opens.
	var docks_before: int = _docks
	await _return_to_boat(20.0)
	_check(_docks == docks_before + 1, "surfacing at the boat docks", "docks %d" % _docks)
	_check(_run.money > 0 and _run.cargo.is_empty(), "docking sells the cargo", "money $%d" % _run.money)
	_check(_encyclopedia.is_unlocked(&"pufferfish", Encyclopedia.Half.BEHAVIOUR) and _encyclopedia.is_unlocked(&"pufferfish", Encyclopedia.Half.WEAK_SPOT),
		"docking unlocks the pending halves (pufferfish complete)", "%d/6 complete" % _encyclopedia.completed_count())
	_check(is_equal_approx(_diver.vitals.oxygen, _diver.config.max_oxygen), "docking refills the tank", "")
	_check(_boat.shop.visible, "the shop opens after a dive", "")

	# 6. Pressing 1 buys the tank only when the money covers it; Space dives again.
	await _check_buy_tank("after the first dive")
	await _tap(KEY_SPACE)
	_check(not _boat.shop.visible, "Space closes the shop", "")

	# 7. The shark: approach -> warning display; back off -> it leaves.
	var shark: Creature = _find_species(&"grey_reef_shark")
	if shark == null:
		_skip("shark checks (display, leave, charge and bite, kill): the shark was already caught")
	else:
		await _shark_fight(shark)

	# 10. Dock, then buy the oxygen tank with the money made so far.
	await _return_to_boat(25.0)
	await _check_buy_tank("after the shark dive")
	await _tap(KEY_SPACE)
	await _dive_out()


func _shark_fight(shark: Creature) -> void:
	var saw_display: bool = await _approach_until(shark, &"display", 15.0)
	_check(saw_display, "approaching the shark makes it show its warning display", "behaviour %s" % shark.behaviour)
	var left: bool = await _back_off_until(shark, &"leave", 6.0)
	_check(left, "backing off makes the shark leave", "behaviour %s" % shark.behaviour)

	# 8. Push in on the shark: it charges and bites.
	await _wait_until(func() -> bool: return shark.behaviour == &"patrol", 10.0)
	var health_before: float = _diver.vitals.health
	var bit: bool = await _approach_until(shark, &"charge", 15.0, true)
	await _wait_until(func() -> bool: return _diver.vitals.health < health_before, 4.0)
	_check(bit and _diver.vitals.health < health_before, "pushing in makes the shark charge and bite",
		"health %.0f -> %.0f" % [health_before, _diver.vitals.health])

	# 9. Kill the shark through its weak spot (the bot knows where it is).
	var shark_killed: bool = await _hunt(shark, 15.0)
	_check(shark_killed, "the harpoon kills the shark", "cargo %d fish" % _run.cargo.size())


## Steps 11-13: death and respawn, diving again, and the tank reaching the dark layer.
func _dive_out() -> void:
	# 11. Run out of oxygen: respawn on the boat, cargo lost, money and tank kept.
	var puffer_like: Creature = _find_species(&"pufferfish")
	if puffer_like == null:
		puffer_like = _find_any_prey()
	var respawns_before: int = _respawns
	var money_before_death: int = _run.money
	var tank_level: int = _run.get_level(&"oxygen_tank")
	await _hold([KEY_S], 3.0)
	if puffer_like != null:
		_run.add_cargo(puffer_like.species) # stand-in catch so the loss is visible
	await _hold_until([KEY_S], func() -> bool: return _respawns > respawns_before, 40.0)
	_check(_respawns == respawns_before + 1, "running out of oxygen respawns the diver", "")
	_check(_diver.get_depth() <= 1.0 and _boat.state == Boat.State.AT_BOAT, "the respawn is on the boat",
		"depth %.1f m" % _diver.get_depth())
	_check(_run.cargo.is_empty() and _run.money == money_before_death and _run.get_level(&"oxygen_tank") == tank_level,
		"death loses the cargo, keeps money and upgrades", "money $%d, tank level %d" % [_run.money, _run.get_level(&"oxygen_tank")])

	# 12. Dive again right away (no shop in the way).
	await _hold([KEY_S], 1.0)
	_check(_diver.get_depth() > 5.0, "can dive again immediately after the respawn", "depth %.1f m" % _diver.get_depth())

	# 13. With the bigger tank, reach the dark layer (150 m) and get back.
	if tank_level < 1:
		_skip("dark-layer round trip: the tank was never affordable this run")
		return
	var docks_before_deep: int = _docks
	await _hold_until([KEY_S], func() -> bool: return _diver.get_depth() >= 150.0, 30.0)
	var reached: float = _diver.get_depth()
	await _return_to_boat(30.0)
	_check(reached >= 150.0 and _docks == docks_before_deep + 1 and _respawns == respawns_before + 1,
		"the level-1 tank reaches the dark layer and returns", "reached %.0f m, oxygen left %.1f" % [reached, _diver.vitals.oxygen])


# --- Checks -------------------------------------------------------------------

## Presses 1 in the open shop: the tank level goes up by one exactly when the money
## covered the next price, and nothing changes otherwise.
func _check_buy_tank(when: String) -> void:
	var level: int = _run.get_level(&"oxygen_tank")
	var money: int = _run.money
	var price: int = _run.get_next_price(&"oxygen_tank")
	var tank: float = _diver.config.max_oxygen
	await _tap(KEY_1)
	if price >= 0 and money >= price:
		_check(_run.get_level(&"oxygen_tank") == level + 1 and _run.money == money - price and _diver.config.max_oxygen > tank,
			"pressing 1 buys the oxygen tank %s" % when,
			"price $%d, money $%d -> $%d, max oxygen %.0f -> %.0f" % [price, money, _run.money, tank, _diver.config.max_oxygen])
	else:
		_check(_run.get_level(&"oxygen_tank") == level and _run.money == money,
			"pressing 1 without enough money buys nothing %s" % when, "price $%d, money $%d" % [price, money])


func _skip(what: String) -> void:
	_skipped += 1
	print("SKIP  %s" % what)


func _check(ok: bool, what: String, detail: String) -> void:
	if ok:
		_passed += 1
	else:
		_failed += 1
	print("%s  %s%s" % ["PASS" if ok else "FAIL", what, ("  [%s]" % detail) if detail != "" else ""])


func _watch_creatures() -> void:
	for creature: Creature in _scene.find_children("*", "Creature", true, false):
		var top: float = creature.global_position.y - creature.species.body_size.y * 0.5
		# The first frame after a spawn is before the creature's own physics step.
		if top < _highest_creature_top and Engine.get_physics_frames() > 2:
			_highest_creature_top = top
			_highest_creature = creature.name


# --- Playing ------------------------------------------------------------------

func _set_key(key: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.keycode = key
	event.pressed = pressed
	Input.parse_input_event(event)


func _tap(key: Key) -> void:
	_set_key(key, true)
	await physics_frame
	_set_key(key, false)
	await physics_frame


func _hold(keys: Array, seconds: float) -> void:
	await _hold_until(keys, func() -> bool: return false, seconds)


func _hold_until(keys: Array, done: Callable, timeout: float) -> void:
	for key: Key in keys:
		_set_key(key, true)
	var t := 0.0
	while t < timeout and not done.call():
		await physics_frame
		t += FRAME
	for key: Key in keys:
		_set_key(key, false)
	await physics_frame


func _wait_until(done: Callable, timeout: float) -> bool:
	var t := 0.0
	while t < timeout and not done.call():
		await physics_frame
		t += FRAME
	return done.call()


## Steers the diver one frame toward [param target] with WASD.
func _steer_toward(target: Vector2, stop_distance: float) -> void:
	var to: Vector2 = target - _diver.global_position
	var go := to.length() > stop_distance
	_set_key(KEY_D, go and to.x > 8.0)
	_set_key(KEY_A, go and to.x < -8.0)
	_set_key(KEY_S, go and to.y > 8.0)
	_set_key(KEY_W, go and to.y < -8.0)


func _release_all() -> void:
	for key: Key in [KEY_W, KEY_A, KEY_S, KEY_D]:
		_set_key(key, false)
	await physics_frame


func _return_to_boat(timeout: float) -> void:
	var docks_before: int = _docks
	var t := 0.0
	while t < timeout and _docks == docks_before:
		_steer_toward(Vector2(_boat.global_position.x, 0.0), 4.0)
		await physics_frame
		t += FRAME
	await _release_all()


## Swims toward [param creature] until its behaviour becomes [param behaviour].
## With [param keep_pushing], keeps swimming at it after that behaviour starts.
func _approach_until(creature: Creature, behaviour: StringName, timeout: float, keep_pushing: bool = false) -> bool:
	var t := 0.0
	while t < timeout and is_instance_valid(creature) and creature.behaviour != behaviour:
		_steer_toward(creature.global_position, 30.0)
		await physics_frame
		t += FRAME
	var reached: bool = is_instance_valid(creature) and creature.behaviour == behaviour
	if keep_pushing and reached:
		var push := 0.0
		while push < 1.5 and is_instance_valid(creature):
			_steer_toward(creature.global_position, 0.0)
			await physics_frame
			push += FRAME
	await _release_all()
	return reached


func _back_off_until(creature: Creature, behaviour: StringName, timeout: float) -> bool:
	var t := 0.0
	while t < timeout and is_instance_valid(creature) and creature.behaviour != behaviour:
		var away: Vector2 = _diver.global_position + (_diver.global_position - creature.global_position).normalized() * 200.0
		away.y = maxf(away.y, 40.0)
		_steer_toward(away, 0.0)
		await physics_frame
		t += FRAME
	await _release_all()
	return is_instance_valid(creature) and creature.behaviour == behaviour


## Closes in to harpoon range and fires at the creature's weak spot until it dies.
func _hunt(creature: Creature, timeout: float) -> bool:
	var t := 0.0
	var range_px: float = _gun.config.harpoon_max_range * 0.6
	while t < timeout and is_instance_valid(creature) and creature.health > 0.0:
		var aim: Vector2 = creature.get_weak_spot_global_position() if creature.species.weak_spot_radius > 0.0 else creature.global_position
		if _diver.global_position.distance_to(aim) > range_px:
			_steer_toward(aim, range_px * 0.8)
		else:
			_steer_toward(_diver.global_position, 1.0)
			_gun.fire_at(aim)
		await physics_frame
		t += FRAME
	await _release_all()
	return not is_instance_valid(creature) or creature.health <= 0.0


func _find_species(species_id: StringName) -> Creature:
	for creature: Creature in _scene.find_children("*", "Creature", true, false):
		if creature.species_id == species_id and creature.health > 0.0:
			return creature
	return null


func _find_any_prey() -> Creature:
	for creature: Creature in _scene.find_children("*", "Creature", true, false):
		if creature.species.ai_kind != SpeciesData.AiKind.PREDATOR and creature.health > 0.0:
			return creature
	return null
