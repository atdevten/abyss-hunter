class_name HelpSection
extends Resource
## One text part of the how-to-play screen: a heading and its lines.
## Part of [HelpContent] (Story 014).

## Heading, e.g. "Warnings".
@export var heading: String = ""
## One line (or list item) each; long lines wrap.
@export var lines: Array[String] = []
## The goal: heading in Signal Yellow (art bible §7: yellow marks the target), shown
## across the full width above the two columns. Other sections go in the right column.
@export var highlight: bool = false
