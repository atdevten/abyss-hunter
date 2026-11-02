class_name Shop
extends Control
## The boat's shop screen: the money, what the last dive sold, and one row per upgrade
## (level, what the next level gives, its price, a buy button). Opens when the diver
## docks ([method open_after_dive]) or with [constant Boat.SHOP_KEY] at the boat.
## Number keys 1..n buy the n-th upgrade; Dive (button, Space or Enter) closes it.
## Reads and spends through the bound [RunState]; the rows come from its upgrade data.
## Blocks clicks to the game while open. Put it on a CanvasLayer.
## Implements Story 006 (production/epics/abyss-hunter/story-006-boat-loop.md).
##
## Usage:
## [codeblock]
## var shop: Shop = load("res://src/boat/shop.tscn").instantiate()
## canvas_layer.add_child(shop)
## shop.bind(run_state)
## shop.dive_requested.connect(_on_dive)
## shop.open_after_dive(fish_sold, money_earned, halves_committed)
## [/codeblock]

## Emitted when the player closes the shop to dive.
signal dive_requested()

## Keys that close the shop, like the Dive button.
const DIVE_KEYS: Array[Key] = [KEY_SPACE, KEY_ENTER]
# Layout and colors (visual only).
const PANEL_COLOR := Color(0.08, 0.06, 0.04, 0.94)
const PANEL_MARGIN := 24.0
const MONEY_COLOR := Color(1.0, 0.85, 0.3)
const DIM_TEXT_COLOR := Color(0.72, 0.72, 0.72)
const TITLE_FONT_SIZE := 30
const MONEY_FONT_SIZE := 22
const NAME_COLUMN_WIDTH := 190.0
const NEXT_COLUMN_WIDTH := 360.0
const BUTTON_WIDTH := 120.0

var _run: RunState
var _money_label: Label
var _report_label: Label
var _footer_label: Label
var _rows: GridContainer
# Per upgrade, in [member UpgradesConfig.upgrades] order.
var _level_labels: Array[Label] = []
var _next_labels: Array[Label] = []
var _buttons: Array[Button] = []


func _ready() -> void:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	var background := StyleBoxFlat.new()
	background.bg_color = PANEL_COLOR
	background.set_content_margin_all(PANEL_MARGIN)
	panel.add_theme_stylebox_override("panel", background)
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	panel.add_child(content)
	_add_label(content, "The Boat", TITLE_FONT_SIZE, Color.WHITE).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_money_label = _add_label(content, "", MONEY_FONT_SIZE, MONEY_COLOR)
	_report_label = _add_label(content, "No dive yet.", 0, DIM_TEXT_COLOR)
	_rows = GridContainer.new()
	_rows.columns = 4
	_rows.add_theme_constant_override("h_separation", 16)
	_rows.add_theme_constant_override("v_separation", 10)
	content.add_child(_rows)
	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	footer.add_theme_constant_override("separation", 16)
	content.add_child(footer)
	_footer_label = _add_label(footer, "", 0, DIM_TEXT_COLOR)
	var dive_button := Button.new()
	dive_button.text = "Dive"
	dive_button.focus_mode = Control.FOCUS_NONE
	dive_button.custom_minimum_size.x = BUTTON_WIDTH
	dive_button.pressed.connect(close_to_dive)
	footer.add_child(dive_button)
	hide()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if not visible or not key or not key.pressed or key.echo:
		return
	var index: int = key.physical_keycode - KEY_1
	if index >= 0 and index < _buttons.size():
		_run.buy(_run.upgrades.upgrades[index].id)
	elif key.physical_keycode in DIVE_KEYS:
		close_to_dive()
	else:
		return
	get_viewport().set_input_as_handled()


## Builds one row per upgrade of [param run] and keeps the screen in sync with it.
func bind(run: RunState) -> void:
	_run = run
	for i in run.upgrades.upgrades.size():
		var upgrade: UpgradeData = run.upgrades.upgrades[i]
		_add_label(_rows, "[%d] %s" % [i + 1, upgrade.display_name], 0, Color.WHITE).custom_minimum_size.x = NAME_COLUMN_WIDTH
		_level_labels.append(_add_label(_rows, "", 0, DIM_TEXT_COLOR))
		var next_label: Label = _add_label(_rows, "", 0, Color.WHITE)
		next_label.custom_minimum_size.x = NEXT_COLUMN_WIDTH
		next_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_next_labels.append(next_label)
		var button := Button.new()
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size.x = BUTTON_WIDTH
		button.pressed.connect(run.buy.bind(upgrade.id))
		_rows.add_child(button)
		_buttons.append(button)
	_footer_label.text = "[1-%d] buy    [Space] dive" % _buttons.size()
	run.money_changed.connect(_refresh.unbind(1))
	run.upgrade_changed.connect(_refresh.unbind(2))
	_refresh()


## Shows the shop with the report of the dive that just ended.
func open_after_dive(fish_sold: int, money_earned: int, halves_committed: int) -> void:
	_report_label.text = "Dive over: sold %d fish for $%d, %d encyclopedia halves unlocked." % [fish_sold, money_earned, halves_committed]
	show()


## Shows the shop between dives (opened at the boat with no dive just ended).
func open_at_boat() -> void:
	_report_label.text = "At the boat."
	show()


## Closes the shop and lets the diver dive.
func close_to_dive() -> void:
	hide()
	dive_requested.emit()


func _refresh() -> void:
	_money_label.text = "Money: $%d" % _run.money
	for i in _buttons.size():
		var upgrade: UpgradeData = _run.upgrades.upgrades[i]
		var level: int = _run.get_level(upgrade.id)
		var price: int = _run.get_next_price(upgrade.id)
		_level_labels[i].text = "Level %d/%d" % [level, upgrade.get_max_level()]
		_next_labels[i].text = "Next: %s" % upgrade.level_names[level] if price >= 0 else "Max level"
		_buttons[i].text = "Buy $%d" % price if price >= 0 else "Owned"
		_buttons[i].disabled = not _run.can_buy(upgrade.id)


func _add_label(parent: Control, text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	if font_size > 0:
		label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label
