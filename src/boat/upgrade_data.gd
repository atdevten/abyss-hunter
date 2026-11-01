class_name UpgradeData
extends Resource
## One boat upgrade: its levels, the price of each, and the bonus each level gives.
## Level 0 is the starting gear (no bonus); level n costs [code]prices[n - 1][/code]
## and gives [code]bonuses[n - 1][/code] in total. What a bonus means depends on the
## upgrade (see [Boat]): extra max oxygen, extra harpoon damage, or 1 = red lamp unlocked.
## Implements Story 006 (production/epics/abyss-hunter/story-006-boat-loop.md).
##
## Usage:
## [codeblock]
## var upgrade: UpgradeData = upgrades_config.get_upgrade(&"oxygen_tank")
## var price: int = upgrade.prices[current_level]   # when current_level < get_max_level()
## [/codeblock]

## Identifier used by [RunState] and [Boat]: oxygen_tank, harpoon or red_lamp.
@export var id: StringName
## Name shown in the shop.
@export var display_name: String = ""
## Price in money of each level, from level 1 up.
@export var prices: Array[int] = []
## Total bonus at each level, from level 1 up (same length as [member prices]).
@export var bonuses: Array[float] = []
## Shop text for each level, from level 1 up (same length as [member prices]).
@export var level_names: Array[String] = []


## The highest level that can be bought.
func get_max_level() -> int:
	return prices.size()
