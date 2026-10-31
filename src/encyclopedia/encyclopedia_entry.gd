class_name EncyclopediaEntry
extends Resource
## Text of one encyclopedia entry: one species, two halves. The first half is earned
## by a photo (behaviour for prey, the warning sign for predators), the second by a
## kill (the weak spot). One [code].tres[/code] per species in
## [code]src/encyclopedia/entries/[/code], listed in an [EncyclopediaBook].
## Implements Story 005 (production/epics/abyss-hunter/story-005-encyclopedia.md).

## Same id as [member SpeciesData.species_id]; the camera and creatures report it.
@export var species_id: StringName
@export var display_name: String
## Heading of the first half: "Behaviour" for prey, "Warning sign" for predators.
@export var first_half_name: String = "Behaviour"
## First half, unlocked by a photo.
@export_multiline var behaviour_text: String
## Second half, unlocked by a kill.
@export_multiline var weak_spot_text: String
