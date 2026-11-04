class_name HelpContent
extends Resource
## Every string of the how-to-play screen ([HelpScreen]), so it can be translated
## without touching code: the title, the controls list, the text sections, the footer
## and the corner hint. Key ids go through [method get_key_label], the one lookup to
## swap for gamepad glyphs later.
## Implements Story 014 (production/epics/abyss-hunter/story-014-how-to-play.md).
##
## Usage:
## [codeblock]
## var content: HelpContent = load("res://src/help/help_content.tres")
## print(content.title, content.get_key_label("mouse_left"))
## [/codeblock]

@export var title: String = ""
@export var controls_heading: String = ""
@export var controls: Array[HelpControl] = []
## Goal, loop and warnings; see [member HelpSection.highlight] for placement.
@export var sections: Array[HelpSection] = []
## Footer key-hint line: keycaps joined by [member footer_key_separator], then the text.
@export var footer_keys: Array[String] = []
@export var footer_key_separator: String = "/"
@export var footer_text: String = ""
## Corner hint shown while the screen is closed: "[<hint_key>] <hint_text>".
@export var hint_key: String = "H"
@export var hint_text: String = ""
## Display text per key id; an id not listed is shown as itself ("W", "F1").
@export var key_labels: Dictionary[String, String] = {}


## The text shown on the keycap for [param key_id].
func get_key_label(key_id: String) -> String:
	return key_labels.get(key_id, key_id)
