class_name RunState
extends RefCounted
## The run's session state: the fish caught this dive (cargo), the money and the
## upgrade levels bought. Session only, never saved (the MVP is played in one sitting).
## Death loses only the cargo ([method lose_dive]); money and upgrades are kept. The
## encyclopedia's pending halves live in [Encyclopedia]; [Boat] commits or discards
## them together with selling or losing the cargo.
## Implements Story 006 (production/epics/abyss-hunter/story-006-boat-loop.md).
##
## Usage:
## [codeblock]
## var run := RunState.new(load("res://src/boat/upgrades.tres"))
## creature.died.connect(func(who: Creature) -> void: run.add_cargo(who.species))
## var earned: int = run.sell_cargo()   # at the boat
## run.buy(&"oxygen_tank")
## [/codeblock]

## Emitted when a fish is added to the cargo or the cargo is sold or lost.
signal cargo_changed(fish_count: int, value: int)
## Emitted when the money changes.
signal money_changed(money: int)
## Emitted when an upgrade's level changes (bought, or set by a debug arg).
signal upgrade_changed(upgrade: UpgradeData, level: int)

## Upgrade data: prices, levels, bonuses. Read-only by convention.
var upgrades: UpgradesConfig
var money: int = 0
## Fish caught this dive, in catch order.
var cargo: Array[SpeciesData] = []

var _levels: Dictionary[StringName, int] = {}


func _init(upgrades_config: UpgradesConfig) -> void:
	upgrades = upgrades_config


## Puts a caught fish of [param species] in the cargo.
func add_cargo(species: SpeciesData) -> void:
	cargo.append(species)
	cargo_changed.emit(cargo.size(), get_cargo_value())


## Total [member SpeciesData.sell_value] of the cargo.
func get_cargo_value() -> int:
	var total: int = 0
	for species in cargo:
		total += species.sell_value
	return total


## Sells the whole cargo: empties it and adds its value to the money. Returns the money earned.
func sell_cargo() -> int:
	var earned: int = get_cargo_value()
	cargo.clear()
	cargo_changed.emit(0, 0)
	add_money(earned)
	return earned


## The dive was lost (the diver died): empties the cargo, keeps money and upgrades.
## Returns how many fish were lost.
func lose_dive() -> int:
	var lost: int = cargo.size()
	cargo.clear()
	cargo_changed.emit(0, 0)
	return lost


## Adds [param amount] (negative to spend) to the money.
func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)


## Current level of the upgrade [param upgrade_id] (0 = not bought).
func get_level(upgrade_id: StringName) -> int:
	return _levels.get(upgrade_id, 0)


## Total bonus of [param upgrade_id] at its current level (0 at level 0).
func get_bonus(upgrade_id: StringName) -> float:
	var level: int = get_level(upgrade_id)
	return 0.0 if level == 0 else upgrades.get_upgrade(upgrade_id).bonuses[level - 1]


## Price of the next level of [param upgrade_id], or -1 when it is at its max level.
func get_next_price(upgrade_id: StringName) -> int:
	var upgrade: UpgradeData = upgrades.get_upgrade(upgrade_id)
	var level: int = get_level(upgrade_id)
	return upgrade.prices[level] if level < upgrade.get_max_level() else -1


## True when the next level of [param upgrade_id] exists and is affordable.
func can_buy(upgrade_id: StringName) -> bool:
	var price: int = get_next_price(upgrade_id)
	return price >= 0 and money >= price


## Buys the next level of [param upgrade_id] if [method can_buy]. Returns whether it did.
func buy(upgrade_id: StringName) -> bool:
	if not can_buy(upgrade_id):
		return false
	add_money(-get_next_price(upgrade_id))
	set_level(upgrade_id, get_level(upgrade_id) + 1)
	return true


## Sets the level of [param upgrade_id] without paying (run setup and debug args).
func set_level(upgrade_id: StringName, level: int) -> void:
	_levels[upgrade_id] = level
	upgrade_changed.emit(upgrades.get_upgrade(upgrade_id), level)
