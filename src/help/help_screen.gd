class_name HelpScreen
extends Control
## The how-to-play screen: controls (keycaps), goal, the loop and warnings, all text
## from a [HelpContent]. [constant TOGGLE_KEYS] (H, F1) open and close it; while open
## the game is paused ([member SceneTree.paused]) so reading costs no oxygen or health.
## This node runs while paused ([constant Node.PROCESS_MODE_ALWAYS], set in the scene).
## While closed a small corner hint says how to reopen it. The "seen" flag lives in
## [constant SETTINGS_PATH] (a settings file, not game progress): [method close] writes
## it when [member remember_seen] is true. Put it on its own CanvasLayer above the other
## screens; [signal opened] is the cue to close them (at most one modal panel).
## Style per art bible §7; fonts, sizes and keycap look are the constants below and
## [member font] (Story 012 restyles here).
## Implements Story 014 (production/epics/abyss-hunter/story-014-how-to-play.md).
##
## Usage:
## [codeblock]
## var help: HelpScreen = load("res://src/help/help_screen.tscn").instantiate()
## canvas_layer.add_child(help)
## help.opened.connect(other_screen.hide)
## if not help.is_seen():
##     help.open()
## [/codeblock]

## Emitted after the screen opened and the game paused.
signal opened()
## Emitted after the screen closed and the game resumed.
signal closed()

const TOGGLE_KEYS: Array[Key] = [KEY_H, KEY_F1]
const SETTINGS_PATH := "user://settings.cfg"
const SETTINGS_SECTION := "ui"
const SETTINGS_KEY_SEEN := "help_seen"
# Colours (visual, art bible §7).
const PANEL_COLOR := Color("#0E1E36")
const TEXT_COLOR := Color("#E6F0FA")
const ACCENT_COLOR := Color("#FFE14D") # Signal Yellow: the goal heading only
const OUTLINE_COLOR := Color("#050812")
const BACKDROP_COLOR := Color(0.02, 0.03, 0.07, 0.6)
const KEYCAP_FILL_COLOR := Color("#16294A")
const KEYCAP_BORDER_COLOR := Color("#E6F0FA")
const HINT_ALPHA := 1.0 # fully opaque: art bible §7 contrast >= 4.5:1 over bright water
# Font sizes in px at 1152x648 (art bible §7: title 28, body 20, never below 18).
const TITLE_FONT_SIZE := 28
const HEADING_FONT_SIZE := 22
const BODY_FONT_SIZE := 20
const KEYCAP_FONT_SIZE := 18
const HINT_FONT_SIZE := 18
const HINT_OUTLINE_SIZE := 2
# Layout in px (visual): the panel fits the 1152x648 viewport with a 12 px border.
const PANEL_SIZE := Vector2(1128.0, 624.0)
const PANEL_PADDING := 20.0
const LEFT_COLUMN_WIDTH := 500.0
const KEY_COLUMN_WIDTH := 176.0
const COLUMN_SEPARATION := 32
const BLOCK_SEPARATION := 10
const LINE_SEPARATION := 2
const ROW_SEPARATION := 4
const KEYCAP_SEPARATION := 4
const KEYCAP_BORDER_WIDTH := 2
const KEYCAP_PADDING := 7.0
const KEYCAP_MIN_WIDTH := 30.0
const HINT_MARGIN := 12.0

## All the screen's text.
@export var content: HelpContent
## Font for every label; null keeps the theme default (Story 012 sets the pixel font).
@export var font: Font
## True: closing writes help_seen=true to [member settings_path]. False (--no-help,
## the playtest bot): the settings file is never touched.
var remember_seen: bool = true
## Settings file holding the seen flag; change it before [method open] / [method close]
## to keep tests off the player's file.
var settings_path: String = SETTINGS_PATH

var _overlay: Control
var _hint: Label
var _paused_before: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ui_theme := Theme.new()
	ui_theme.default_font_size = BODY_FONT_SIZE
	if font:
		ui_theme.default_font = font
	ui_theme.set_color("font_color", "Label", TEXT_COLOR)
	theme = ui_theme
	_build_overlay()
	_build_hint()
	_overlay.hide()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.physical_keycode in TOGGLE_KEYS:
		toggle()
		get_viewport().set_input_as_handled()
	elif is_open() and (event is InputEventKey or event is InputEventMouseButton):
		# Paused nodes get no input anyway; this guards any node that runs while paused.
		get_viewport().set_input_as_handled()


## True while the screen is shown.
func is_open() -> bool:
	return _overlay.visible


## Shows the screen and pauses the game. Does nothing when already open.
func open() -> void:
	if is_open():
		return
	_paused_before = get_tree().paused
	get_tree().paused = true
	_overlay.show()
	_hint.hide()
	opened.emit()


## Hides the screen, resumes the game and, with [member remember_seen], records that
## the help was seen. Does nothing when already closed.
func close() -> void:
	if not is_open():
		return
	_overlay.hide()
	_hint.show()
	get_tree().paused = _paused_before
	if remember_seen and not is_seen():
		_save_seen()
	closed.emit()


func toggle() -> void:
	if is_open():
		close()
	else:
		open()


## True when [member settings_path] has help_seen=true (the help was closed once).
func is_seen() -> bool:
	var config := ConfigFile.new()
	return config.load(settings_path) == OK and config.get_value(SETTINGS_SECTION, SETTINGS_KEY_SEEN, false) == true


func _save_seen() -> void:
	var config := ConfigFile.new()
	config.load(settings_path) # keeps other settings; a missing file starts empty
	config.set_value(SETTINGS_SECTION, SETTINGS_KEY_SEEN, true)
	var error: Error = config.save(settings_path)
	if error != OK:
		push_warning("HelpScreen: could not save %s (%s)" % [settings_path, error_string(error)])


func _build_overlay() -> void:
	_overlay = Control.new()
	_overlay.name = "Overlay"
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP # no click reaches the game below
	add_child(_overlay)
	var backdrop := ColorRect.new()
	backdrop.color = BACKDROP_COLOR
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(backdrop)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = PANEL_SIZE
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.set_content_margin_all(PANEL_PADDING)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)
	var body := _add_vbox(panel, BLOCK_SEPARATION)
	_add_label(body, content.title, TITLE_FONT_SIZE).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for section: HelpSection in content.sections:
		if section.highlight:
			_add_section(body, section)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", COLUMN_SEPARATION)
	columns.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(columns)
	var left := _add_vbox(columns, ROW_SEPARATION)
	left.custom_minimum_size.x = LEFT_COLUMN_WIDTH
	_add_label(left, content.controls_heading, HEADING_FONT_SIZE)
	for row: HelpControl in content.controls:
		_add_control_row(left, row)
	var right := _add_vbox(columns, BLOCK_SEPARATION)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for section: HelpSection in content.sections:
		if not section.highlight:
			_add_section(right, section)
	# Key-hint line at the panel's foot (art bible §7).
	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", KEYCAP_SEPARATION * 2)
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(footer)
	for i in content.footer_keys.size():
		if i > 0:
			_add_label(footer, content.footer_key_separator, BODY_FONT_SIZE)
		footer.add_child(_make_keycap(content.footer_keys[i]))
	_add_label(footer, content.footer_text, BODY_FONT_SIZE)


func _build_hint() -> void:
	_hint = _add_label(self, "[%s] %s" % [content.get_key_label(content.hint_key), content.hint_text], HINT_FONT_SIZE)
	_hint.name = "Hint"
	_hint.modulate.a = HINT_ALPHA
	_hint.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	_hint.add_theme_constant_override("outline_size", HINT_OUTLINE_SIZE)
	# Bottom-right corner, growing up and left from the margin.
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_hint.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_hint.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_hint.offset_left = -HINT_MARGIN
	_hint.offset_top = -HINT_MARGIN
	_hint.offset_right = -HINT_MARGIN
	_hint.offset_bottom = -HINT_MARGIN


func _add_section(parent: Control, section: HelpSection) -> void:
	var box := _add_vbox(parent, LINE_SEPARATION)
	var heading := _add_label(box, section.heading, HEADING_FONT_SIZE)
	if section.highlight:
		heading.add_theme_color_override("font_color", ACCENT_COLOR)
	for line in section.lines:
		_add_label(box, line, BODY_FONT_SIZE).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _add_control_row(parent: Control, row: HelpControl) -> void:
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", KEYCAP_SEPARATION * 3)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(line)
	var keys := HBoxContainer.new()
	keys.add_theme_constant_override("separation", KEYCAP_SEPARATION)
	keys.custom_minimum_size.x = KEY_COLUMN_WIDTH
	keys.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(keys)
	for key_id in row.keys:
		keys.add_child(_make_keycap(key_id))
	var description := _add_label(line, row.description, BODY_FONT_SIZE)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description.size_flags_vertical = Control.SIZE_SHRINK_CENTER


## A keycap: the key's label in a bordered rectangle, no semantic colour (art bible §7).
func _make_keycap(key_id: String) -> PanelContainer:
	var cap := PanelContainer.new()
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cap.custom_minimum_size.x = KEYCAP_MIN_WIDTH
	cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var style := StyleBoxFlat.new()
	style.bg_color = KEYCAP_FILL_COLOR
	style.border_color = KEYCAP_BORDER_COLOR
	style.set_border_width_all(KEYCAP_BORDER_WIDTH)
	style.content_margin_left = KEYCAP_PADDING
	style.content_margin_right = KEYCAP_PADDING
	cap.add_theme_stylebox_override("panel", style)
	_add_label(cap, content.get_key_label(key_id), KEYCAP_FONT_SIZE).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return cap


func _add_vbox(parent: Control, separation: int) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", separation)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(box)
	return box


func _add_label(parent: Control, text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if font_size != BODY_FONT_SIZE:
		label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label
