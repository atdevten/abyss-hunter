class_name Encyclopedia
extends RefCounted
## The session's encyclopedia unlock state, the one object that knows what the player
## has learned. Each species in the [EncyclopediaBook] has two halves, each LOCKED,
## PENDING or UNLOCKED:
## [codeblock]
## LOCKED  --record_photo (BEHAVIOUR) / record_kill (WEAK_SPOT)--> PENDING
## PENDING --commit_pending (diver reached the boat)--> UNLOCKED
## PENDING --discard_pending (diver died)--> LOCKED
## [/codeblock]
## Only UNLOCKED halves give advantages in play ([method is_unlocked]); creatures read
## them through [member CreatureContext.encyclopedia], the HUD and
## [EncyclopediaScreen] through the signals. Death discards both pending halves: the
## brief has the diver lose every fish and photo carried, and a kill's knowledge rides
## with the catch. Session-only, never saved to disk.
## Implements Story 005 (production/epics/abyss-hunter/story-005-encyclopedia.md).
##
## Usage:
## [codeblock]
## var encyclopedia := Encyclopedia.new(load("res://src/encyclopedia/encyclopedia_book.tres"))
## camera_tool.photo_taken.connect(encyclopedia.record_photo)
## creature.died.connect(func(who: Creature) -> void: encyclopedia.record_kill(who.species_id))
## vitals.diver_died.connect(func(_cause: DiverVitals.Cause) -> void: encyclopedia.discard_pending())
## boat_reached.connect(encyclopedia.commit_pending)   # Story 006
## encyclopedia.completed.connect(_on_win)
## [/codeblock]

## The two halves of an entry. BEHAVIOUR is the photo half (behaviour for prey,
## warning sign for predators); WEAK_SPOT is the kill half.
enum Half { BEHAVIOUR, WEAK_SPOT }
enum State { LOCKED, PENDING, UNLOCKED }

## Emitted whenever a half changes state.
signal entry_changed(species_id: StringName, half: Half, state: State)
## Emitted once, when a commit completes the last entry: the win.
signal completed()

## The content this state tracks.
var book: EncyclopediaBook

## species_id -> [State of BEHAVIOUR, State of WEAK_SPOT].
var _states: Dictionary[StringName, Array] = {}


func _init(entry_book: EncyclopediaBook) -> void:
	book = entry_book
	for entry in book.entries:
		_states[entry.species_id] = [State.LOCKED, State.LOCKED]


## A photo of [param species_id]: its BEHAVIOUR half becomes PENDING if it was LOCKED.
## Returns whether anything changed (false for known halves and for ids with no
## entry, such as test targets).
func record_photo(species_id: StringName) -> bool:
	return _record(species_id, Half.BEHAVIOUR)


## A harpoon kill of [param species_id]: its WEAK_SPOT half becomes PENDING if it
## was LOCKED. Returns whether anything changed.
func record_kill(species_id: StringName) -> bool:
	return _record(species_id, Half.WEAK_SPOT)


## The diver reached the boat: every PENDING half becomes UNLOCKED. Emits
## [signal completed] when this completes the last entry. Returns how many halves
## were committed.
func commit_pending() -> int:
	var count: int = _move_pending(State.UNLOCKED)
	if count > 0 and is_complete():
		completed.emit()
	return count


## The diver died: every PENDING half goes back to LOCKED. Returns how many were lost.
func discard_pending() -> int:
	return _move_pending(State.LOCKED)


## State of [param half] of [param species_id]'s entry.
func get_state(species_id: StringName, half: Half) -> State:
	return _states[species_id][half]


## True when [param half] of [param species_id] is committed, i.e. its advantage
## shows in play. False for ids with no entry.
func is_unlocked(species_id: StringName, half: Half) -> bool:
	return _states.has(species_id) and _states[species_id][half] == State.UNLOCKED


## Number of entries with both halves UNLOCKED.
func completed_count() -> int:
	var count: int = 0
	for halves: Array in _states.values():
		if halves.all(func(state: State) -> bool: return state == State.UNLOCKED):
			count += 1
	return count


## Number of halves waiting to be brought to the boat.
func pending_count() -> int:
	var count: int = 0
	for halves: Array in _states.values():
		count += halves.count(State.PENDING)
	return count


## True when every entry is complete (the win state).
func is_complete() -> bool:
	return completed_count() == book.entries.size()


func _record(species_id: StringName, half: Half) -> bool:
	if not _states.has(species_id) or _states[species_id][half] != State.LOCKED:
		return false
	_states[species_id][half] = State.PENDING
	entry_changed.emit(species_id, half, State.PENDING)
	return true


func _move_pending(to: State) -> int:
	var count: int = 0
	for species_id: StringName in _states:
		for half: Half in Half.values():
			if _states[species_id][half] == State.PENDING:
				_states[species_id][half] = to
				entry_changed.emit(species_id, half, to)
				count += 1
	return count
