class_name EcosystemConfig
extends Resource
## Tuning data for the minimal food chain (Story 007): one [LayerPopulationData] per
## depth layer, and where a migrating predator settles. Depths in meters.
## Implements Story 007 (production/epics/abyss-hunter/story-007-food-chain.md).
##
## Usage:
## [codeblock]
## var config: EcosystemConfig = load("res://src/ecosystem/ecosystem_config.tres")
## var population := Population.new(config, layers_config, diver_config.pixels_per_meter)
## [/codeblock]

## Per-layer prey tuning, shallow to deep, parallel to [member LayersConfig.layers].
@export var layers: Array[LayerPopulationData] = []
## A predator migrating up patrols this many meters above the bottom of the
## shallower layer (the boundary with its home layer).
@export var migration_depth_above_boundary: float = 12.0
