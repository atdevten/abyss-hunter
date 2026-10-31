class_name SpeciesData
extends Resource
## Tuning data for one species: stats, AI kind and its behaviour knobs, weak spot,
## blood and light reactions, and the placeholder look. One [code].tres[/code] per
## species in [code]src/creatures/species/[/code]. Distances are in pixels, times in
## seconds, speeds in pixels per second.
## Implements Story 003 (production/epics/abyss-hunter/story-003-species-ai-blood.md).
##
## Usage:
## [codeblock]
## var creature: Creature = CREATURE_SCENE.instantiate()
## creature.species = load("res://src/creatures/species/grey_reef_shark.tres")
## [/codeblock]

## Which AI component a creature of this species gets.
enum AiKind { PASSIVE, FLEEING, PREDATOR }
## Placeholder drawing style.
enum BodyShape { FISH, PUFFER, JELLY, SQUID }

@export_group("Identity")
## Id reported to the camera and the encyclopedia.
@export var species_id: StringName
@export var display_name: String
@export var ai_kind: AiKind = AiKind.PASSIVE

@export_group("Stats")
## Top swim speed.
@export var speed: float = 60.0
@export var health: float = 20.0
## Damage dealt to the diver by one attack (predators only).
@export var damage: float = 0.0
## Money paid at the boat for one catch.
@export var sell_value: int = 0
## Distance at which the diver (and, for fleeing species, a predator) is noticed. 0 = never.
@export var aggro_radius: float = 0.0

@export_group("Movement")
## Steering acceleration in pixels per second squared.
@export var acceleration: float = 120.0
## Fraction of [member speed] used while wandering.
@export var cruise_speed_fraction: float = 0.4
## How far from its spawn point the creature wanders.
@export var wander_radius: float = 80.0
## Seconds before a new wander point is picked.
@export var wander_retarget_time: float = 3.0

@export_group("Weak Spot")
## Weak spot center in local pixels, for the creature facing right (+x).
@export var weak_spot_offset: Vector2 = Vector2.ZERO
## Weak spot radius in pixels. 0 = no weak spot.
@export var weak_spot_radius: float = 6.0
## Harpoon damage multiplier when the hit lands in the weak spot.
@export var weak_spot_multiplier: float = 1.5

@export_group("Blood And Light")
## Radius within which the blood lure from a hit attracts predators. 0 = does not bleed.
@export var blood_lure_radius: float = 0.0
## Seconds the blood lure lasts before it has faded away.
@export var blood_lure_duration: float = 6.0
## Seconds the creature glows after being hit. 0 = does not flash.
@export var flash_on_hit_duration: float = 0.0
## Radius of the flash glow (visual; Story 004 uses it for luring).
@export var flash_radius: float = 0.0

@export_group("Lamp And Glow")
## Swims to the diver's white lamp in a layer whose lamp reaction is ATTRACT (small fish).
## Story 004.
@export var drawn_to_lamp: bool = false
## Takes no notice of the lamp in a layer whose lamp reaction is REPEL (the "most
## creatures move away" exceptions). Story 004.
@export var ignores_lamp: bool = false
## Radius in pixels of the creature's own bioluminescent light. 0 = does not glow.
@export var glow_radius: float = 0.0
@export var glow_color: Color = Color(0.3, 0.7, 1.0)
@export var glow_energy: float = 1.0
## Center of the glow in local pixels, for the creature facing right (+x).
@export var glow_offset: Vector2 = Vector2.ZERO

@export_group("Schooling")
## Schoolmates within this radius pull together. 0 = solitary.
@export var school_radius: float = 0.0
## Distance schoolmates keep from each other when calm.
@export var separation_distance: float = 16.0
## Strength of the pull toward the school's center, relative to speed.
@export var cohesion_weight: float = 0.5
## While a predator is within [member aggro_radius], cohesion is multiplied and
## separation divided by this. 1 = the school does not tighten.
@export var predator_tighten_multiplier: float = 1.0

@export_group("Predator")
## Seconds of warning display before charging. 0 = charges without a display.
@export var display_duration: float = 0.0
## During the display, a diver this close (or closer) triggers the charge.
@export var charge_distance: float = 0.0
## During the display, a diver this far (or farther) makes the predator leave.
@export var leave_distance: float = 0.0
## Charge speed as a multiple of [member speed].
@export var charge_speed_multiplier: float = 2.0
## A charge that has not reached the diver after this long is a miss.
@export var charge_max_time: float = 1.5
## Center-to-center distance at which a charge strikes the diver.
@export var attack_reach: float = 40.0
## Seconds spent swimming off after a charge, hit or miss.
@export var recover_time: float = 2.5
## Seconds spent swimming away after the diver backed off from the display.
@export var leave_time: float = 4.0
## A lured predator slows down within this distance of the blood.
@export var lure_arrive_distance: float = 40.0

@export_group("Knowledge")
## Extra display seconds while encyclopedia knowledge is on (the warning reads earlier).
@export var knowledge_display_extra_time: float = 0.0

@export_group("Look")
@export var body_shape: BodyShape = BodyShape.FISH
## Body length (x) and height (y) in pixels; also the hit box.
@export var body_size: Vector2 = Vector2(32.0, 12.0)
@export var color: Color = Color.WHITE
