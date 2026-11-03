class_name Collection
extends RefCounted
## The session's fish collection: per species, the fish caught, the photos taken and the
## deepest catch (meters). Distinct from the [Encyclopedia] (two knowledge halves per
## species) and the cargo (fish sold at the boat). Every catch and photo is first
## PENDING, like the encyclopedia's halves:
## [codeblock]
## record_catch / record_photo --> pending
## pending --commit_pending (diver reached the boat)--> committed
## pending --discard_pending (diver died)--> lost
## [/codeblock]
## A species is met once it has one committed catch or photo. The species, in display
## order, are the entries of the [EncyclopediaBook]. Session-only, never saved to disk.
## Implements Story 008 (production/epics/abyss-hunter/story-008-fish-collection.md).
##
## Usage:
## [codeblock]
## var collection := Collection.new(load("res://src/encyclopedia/encyclopedia_book.tres"))
## camera_tool.photo_taken.connect(collection.record_photo)
## creature.died.connect(func(who: Creature) -> void: collection.record_catch(who.species_id, depth_m))
## boat.docked.connect(collection.commit_pending.unbind(3))
## boat.respawned.connect(collection.discard_pending.unbind(3))
## [/codeblock]

## Depth returned by the deepest-catch getters for a species with no catch.
const NO_CATCH := -1.0

## Emitted whenever a count or depth changes (record, commit, discard).
signal changed()

## The species list (entries in display order, with their display names).
var book: EncyclopediaBook

# species_id -> committed / pending values.
var _caught: Dictionary[StringName, int] = {}
var _pending_caught: Dictionary[StringName, int] = {}
var _photos: Dictionary[StringName, int] = {}
var _pending_photos: Dictionary[StringName, int] = {}
var _deepest: Dictionary[StringName, float] = {}
var _pending_deepest: Dictionary[StringName, float] = {}


func _init(species_book: EncyclopediaBook) -> void:
	book = species_book
	for entry in book.entries:
		_caught[entry.species_id] = 0
		_photos[entry.species_id] = 0
		_deepest[entry.species_id] = NO_CATCH
	_clear_pending()


## A harpoon kill of [param species_id] at [param depth_m] meters: one pending catch,
## and the pending deepest catch if deeper. Returns false for ids not in the book
## (such as test targets).
func record_catch(species_id: StringName, depth_m: float) -> bool:
	if not _caught.has(species_id):
		return false
	_pending_caught[species_id] += 1
	_pending_deepest[species_id] = maxf(_pending_deepest[species_id], depth_m)
	changed.emit()
	return true


## A photo of [param species_id]: one pending photo. Returns false for ids not in the book.
func record_photo(species_id: StringName) -> bool:
	if not _photos.has(species_id):
		return false
	_pending_photos[species_id] += 1
	changed.emit()
	return true


## The diver reached the boat: pending catches, photos and depths become committed.
## Returns how many catches and photos were committed.
func commit_pending() -> int:
	var count: int = pending_count()
	for species_id: StringName in _caught:
		_caught[species_id] += _pending_caught[species_id]
		_photos[species_id] += _pending_photos[species_id]
		_deepest[species_id] = maxf(_deepest[species_id], _pending_deepest[species_id])
	_clear_pending()
	if count > 0:
		changed.emit()
	return count


## The diver died: everything pending is lost. Returns how many catches and photos were lost.
func discard_pending() -> int:
	var count: int = pending_count()
	_clear_pending()
	if count > 0:
		changed.emit()
	return count


## Committed fish caught of [param species_id].
func get_caught(species_id: StringName) -> int:
	return _caught[species_id]


## Fish of [param species_id] caught this dive, not yet brought to the boat.
func get_pending_caught(species_id: StringName) -> int:
	return _pending_caught[species_id]


## Committed photos of [param species_id].
func get_photos(species_id: StringName) -> int:
	return _photos[species_id]


## Photos of [param species_id] taken this dive, not yet brought to the boat.
func get_pending_photos(species_id: StringName) -> int:
	return _pending_photos[species_id]


## Deepest committed catch of [param species_id] in meters, [constant NO_CATCH] if none.
func get_deepest_catch(species_id: StringName) -> float:
	return _deepest[species_id]


## Deepest pending catch of [param species_id] in meters, [constant NO_CATCH] if none.
func get_pending_deepest_catch(species_id: StringName) -> float:
	return _pending_deepest[species_id]


## True once [param species_id] has a committed catch or photo.
func is_met(species_id: StringName) -> bool:
	return _caught[species_id] > 0 or _photos[species_id] > 0


## Number of species met.
func met_count() -> int:
	return _caught.keys().filter(is_met).size()


## Committed fish caught, all species.
func total_caught() -> int:
	var total: int = 0
	for count: int in _caught.values():
		total += count
	return total


## Pending catches plus pending photos, all species: what a death would lose.
func pending_count() -> int:
	var total: int = 0
	for species_id: StringName in _caught:
		total += _pending_caught[species_id] + _pending_photos[species_id]
	return total


func _clear_pending() -> void:
	for species_id: StringName in _caught:
		_pending_caught[species_id] = 0
		_pending_photos[species_id] = 0
		_pending_deepest[species_id] = NO_CATCH
