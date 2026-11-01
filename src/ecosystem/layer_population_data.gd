class_name LayerPopulationData
extends Resource
## Food chain tuning for one depth layer: its prey stock, how fast the stock recovers,
## and when the layer's predators turn aggressive or move up a layer. Listed in
## [member EcosystemConfig.layers] in the same order as [member LayersConfig.layers].
## Implements Story 007 (production/epics/abyss-hunter/story-007-food-chain.md).

## Prey stock at the start of the run, and the value recovery climbs back toward.
@export var starting_prey: int = 10
## Prey added back to this layer each time the diver docks at the boat (never past
## [member starting_prey]).
@export var recovery_per_dock: int = 3
## Below this stock the layer is HUNGRY: its predators get the aggression multipliers.
@export var aggression_threshold: int = 5
## Below this stock (lower than [member aggression_threshold]) the layer is MIGRATING:
## its predators also move up into the next shallower layer.
@export var migration_threshold: int = 2
## Speed multiplier (patrol travel, display approach, charge) of this layer's predators
## while the layer is HUNGRY or MIGRATING.
@export var aggression_speed_multiplier: float = 1.4
## Aggro radius multiplier of this layer's predators while HUNGRY or MIGRATING.
@export var aggression_aggro_multiplier: float = 1.5
