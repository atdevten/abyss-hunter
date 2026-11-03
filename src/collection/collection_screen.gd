class_name CollectionScreen
extends Control
## The collection screen: one row per species (name, fish caught, photos, deepest
## catch in meters and its depth layer; "???" until the species is met), pending
## numbers shown apart ("+N pending", what a death would lose), and the totals line
## "N / 6 species met · M fish caught". [constant TOGGLE_KEY] shows and hides it; the
## dive does not pause. Reads everything through the bound [Collection]. Put it on a
## CanvasLayer.
## Implements Story 008 (production/epics/abyss-hunter/story-008-fish-collection.md).
##
## Usage:
## [codeblock]
## var screen: CollectionScreen = load("res://src/collection/collection_screen.tscn").instantiate()
## canvas_layer.add_child(screen)
## screen.bind(collection, layers_config)
## [/codeblock]

const TOGGLE_KEY := KEY_C
## Column widths in pixels (layout).
const NAME_COLUMN_WIDTH := 200.0
const COUNT_COLUMN_WIDTH := 210.0
const DEPTH_COLUMN_WIDTH := 400.0
## Panel background (visual), the encyclopedia screen's.
const PANEL_COLOR := Color(0.03, 0.07, 0.14, 0.92)
## Text colours (visual), the encyclopedia screen's LOCKED / PENDING / UNLOCKED ones.
const UNMET_COLOR := Color(0.5, 0.5, 0.55)
const PENDING_COLOR := Color(1.0, 0.7, 0.2)
const MET_COLOR := Color(0.55, 1.0, 0.6)

var _collection: Collection
var _layers: LayersConfig
## species_id -> [name, caught, photos, deepest] labels.
var _cells: Dictionary[StringName, Array] = {}

@onready var _rows: GridContainer = $Panel/Margin/Content/Rows
@onready var _totals: Label = $Panel/Margin/Content/Totals


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


## Builds the rows from [param collection]'s book and keeps them in sync with it;
## [param layers] names the layer of each deepest catch.
func bind(collection: Collection, layers: LayersConfig) -> void:
	_collection = collection
	_layers = layers
	var widths: Array[float] = [NAME_COLUMN_WIDTH, COUNT_COLUMN_WIDTH, COUNT_COLUMN_WIDTH, DEPTH_COLUMN_WIDTH]
	var headings: Array[String] = ["Species", "Fish caught", "Photos", "Deepest catch"]
	for i in headings.size():
		_add_label(headings[i], widths[i]).add_theme_color_override("font_color", Color.WHITE)
	for entry in collection.book.entries:
		_cells[entry.species_id] = widths.map(func(width: float) -> Label: return _add_label("", width))
	collection.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	for entry in _collection.book.entries:
		var id: StringName = entry.species_id
		var cells: Array = _cells[id]
		var met: bool = _collection.is_met(id)
		var pending: bool = _collection.get_pending_caught(id) + _collection.get_pending_photos(id) > 0
		(cells[0] as Label).text = entry.display_name if met else "???"
		(cells[1] as Label).text = _count_text(_collection.get_caught(id), _collection.get_pending_caught(id))
		(cells[2] as Label).text = _count_text(_collection.get_photos(id), _collection.get_pending_photos(id))
		var depth_text: String = _depth_text(_collection.get_deepest_catch(id))
		var pending_depth: float = _collection.get_pending_deepest_catch(id)
		if pending_depth > _collection.get_deepest_catch(id):
			depth_text = "%s  (pending: %s)" % [depth_text, _depth_text(pending_depth)]
		(cells[3] as Label).text = depth_text
		var color: Color = PENDING_COLOR if pending else (MET_COLOR if met else UNMET_COLOR)
		for cell: Label in cells:
			cell.add_theme_color_override("font_color", color)
	_totals.text = "%d / %d species met · %d fish caught   (+%d pending)" % [_collection.met_count(), _collection.book.entries.size(), _collection.total_caught(), _collection.pending_count()]


func _count_text(committed: int, pending: int) -> String:
	return "%d  (+%d pending)" % [committed, pending] if pending > 0 else str(committed)


func _depth_text(depth_m: float) -> String:
	if depth_m == Collection.NO_CATCH:
		return "-"
	return "%.0f m (%s)" % [depth_m, _layers.layers[_layers.get_layer_index(depth_m)].display_name]


func _add_label(text: String, width: float) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = width
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rows.add_child(label)
	return label
