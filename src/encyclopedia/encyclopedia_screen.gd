class_name EncyclopediaScreen
extends Control
## The encyclopedia screen: one row per species with the state of each half (the text
## once unlocked), the "N / 6 complete" count, and the win message once complete.
## [constant TOGGLE_KEY] shows and hides it; the dive does not pause. Reads everything
## through the bound [Encyclopedia]. Put it on a CanvasLayer.
## Implements Story 005 (production/epics/abyss-hunter/story-005-encyclopedia.md).
##
## Usage:
## [codeblock]
## var screen: EncyclopediaScreen = load("res://src/encyclopedia/encyclopedia_screen.tscn").instantiate()
## canvas_layer.add_child(screen)
## screen.bind(encyclopedia)
## [/codeblock]

const TOGGLE_KEY := KEY_E
## Width of the two text columns, in pixels (layout).
const TEXT_COLUMN_WIDTH := 450.0
const NAME_COLUMN_WIDTH := 170.0
## Panel background (visual).
const PANEL_COLOR := Color(0.03, 0.07, 0.14, 0.92)
## Text colour per [enum Encyclopedia.State] (visual).
const STATE_COLORS: Dictionary[Encyclopedia.State, Color] = {
	Encyclopedia.State.LOCKED: Color(0.5, 0.5, 0.55),
	Encyclopedia.State.PENDING: Color(1.0, 0.7, 0.2),
	Encyclopedia.State.UNLOCKED: Color(0.55, 1.0, 0.6),
}

var _encyclopedia: Encyclopedia
## species_id -> [BEHAVIOUR label, WEAK_SPOT label].
var _cells: Dictionary[StringName, Array] = {}

@onready var _rows: GridContainer = $Panel/Margin/Content/Rows
@onready var _count: Label = $Panel/Margin/Content/Count
@onready var _win: Label = $Panel/Margin/Content/Win


func _ready() -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = PANEL_COLOR
	($Panel as PanelContainer).add_theme_stylebox_override("panel", background)
	($Panel/Margin/Content/Footer as Label).text += "   [%s] open / close" % OS.get_keycode_string(TOGGLE_KEY)
	hide()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.physical_keycode == TOGGLE_KEY:
		visible = not visible


## Builds the rows from [param encyclopedia]'s book and keeps them in sync with it.
## When the encyclopedia is completed the win message appears and the screen opens.
func bind(encyclopedia: Encyclopedia) -> void:
	_encyclopedia = encyclopedia
	for heading: String in ["Species", "Behaviour / warning sign (photo)", "Weak spot (kill)"]:
		_add_label(heading, NAME_COLUMN_WIDTH if heading == "Species" else TEXT_COLUMN_WIDTH).add_theme_color_override("font_color", Color.WHITE)
	for entry in encyclopedia.book.entries:
		_add_label(entry.display_name, NAME_COLUMN_WIDTH)
		_cells[entry.species_id] = [_add_label("", TEXT_COLUMN_WIDTH), _add_label("", TEXT_COLUMN_WIDTH)]
	_win.text = encyclopedia.book.win_message
	encyclopedia.entry_changed.connect(_refresh.unbind(3))
	encyclopedia.completed.connect(show)
	_refresh()


func _refresh() -> void:
	for entry in _encyclopedia.book.entries:
		var texts: Array[String] = ["%s: %s" % [entry.first_half_name, entry.behaviour_text], entry.weak_spot_text]
		for half: Encyclopedia.Half in Encyclopedia.Half.values():
			var state: Encyclopedia.State = _encyclopedia.get_state(entry.species_id, half)
			var cell: Label = _cells[entry.species_id][half]
			match state:
				Encyclopedia.State.LOCKED:
					cell.text = "Locked (%s)" % ("photograph it" if half == Encyclopedia.Half.BEHAVIOUR else "hunt it")
				Encyclopedia.State.PENDING:
					cell.text = "Pending: bring it to the boat"
				Encyclopedia.State.UNLOCKED:
					cell.text = texts[half]
			cell.add_theme_color_override("font_color", STATE_COLORS[state])
	_count.text = "%d / %d complete   (%d halves pending)" % [_encyclopedia.completed_count(), _encyclopedia.book.entries.size(), _encyclopedia.pending_count()]
	_win.visible = _encyclopedia.is_complete()


func _add_label(text: String, width: float) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = width
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rows.add_child(label)
	return label
