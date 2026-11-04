class_name HelpControl
extends Resource
## One row of the how-to-play controls list: the keys (ids looked up through
## [method HelpContent.get_key_label], drawn as keycaps) and what they do.
## Part of [HelpContent] (Story 014).

## Key ids, one keycap each, e.g. ["W", "A", "S", "D"] or ["mouse_left"].
@export var keys: Array[String] = []
## What the keys do, e.g. "Swim".
@export var description: String = ""
