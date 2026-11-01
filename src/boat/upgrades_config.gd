class_name UpgradesConfig
extends Resource
## The boat's upgrades, in shop order. Data: [code]src/boat/upgrades.tres[/code].
## Implements Story 006 (production/epics/abyss-hunter/story-006-boat-loop.md).
##
## Usage:
## [codeblock]
## var config: UpgradesConfig = load("res://src/boat/upgrades.tres")
## var tank: UpgradeData = config.get_upgrade(&"oxygen_tank")
## [/codeblock]

## The upgrades, in the order the shop lists them (keys 1, 2, 3...).
@export var upgrades: Array[UpgradeData] = []


## The upgrade with [param upgrade_id].
func get_upgrade(upgrade_id: StringName) -> UpgradeData:
	for upgrade in upgrades:
		if upgrade.id == upgrade_id:
			return upgrade
	return null
