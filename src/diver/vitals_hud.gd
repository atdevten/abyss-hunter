class_name VitalsHud
extends Control
## Minimal HUD: an oxygen bar and a health bar bound to a [DiverVitals].
##
## Usage:
## [codeblock]
## var hud := VitalsHud.new()
## canvas_layer.add_child(hud)
## hud.bind(diver.vitals)
## [/codeblock]

var _oxygen_bar: ProgressBar
var _health_bar: ProgressBar


func _ready() -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(16.0, 16.0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE # the HUD never eats tool clicks
	add_child(box)
	_oxygen_bar = _make_bar(box, Color.DEEP_SKY_BLUE)
	_health_bar = _make_bar(box, Color.RED)


## Connects the bars to [param vitals] and shows its current values.
func bind(vitals: DiverVitals) -> void:
	vitals.oxygen_changed.connect(_set_bar.bind(_oxygen_bar))
	vitals.health_changed.connect(_set_bar.bind(_health_bar))
	_set_bar(vitals.oxygen, vitals.config.max_oxygen, _oxygen_bar)
	_set_bar(vitals.health, vitals.config.max_health, _health_bar)


func _make_bar(parent: Control, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(200.0, 16.0)
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	bar.add_theme_stylebox_override("fill", fill)
	parent.add_child(bar)
	return bar


func _set_bar(current: float, maximum: float, bar: ProgressBar) -> void:
	bar.max_value = maximum
	bar.value = current
