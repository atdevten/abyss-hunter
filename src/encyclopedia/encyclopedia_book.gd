class_name EncyclopediaBook
extends Resource
## The encyclopedia's content: every entry to complete, in display order, and the
## message shown when all are complete (the win). Data only; the unlock state of a
## session lives in an [Encyclopedia].
## Implements Story 005 (production/epics/abyss-hunter/story-005-encyclopedia.md).
##
## Usage:
## [codeblock]
## var encyclopedia := Encyclopedia.new(load("res://src/encyclopedia/encyclopedia_book.tres"))
## [/codeblock]

## One entry per species; completing all of them wins the game.
@export var entries: Array[EncyclopediaEntry] = []
@export var win_message: String = "Encyclopedia complete. You win!"
