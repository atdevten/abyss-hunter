class_name VitalsHud
extends Control
## Minimal HUD: an oxygen bar and a health bar bound to a [DiverVitals], and
## (Story 005) the encyclopedia progress line bound to an [Encyclopedia],
## and (Story 006) the cargo and money bound to a [RunState], and (Story 007) the
## per-layer prey readout bound to a [Population].
##
## Usage:
## [codeblock]
## var hud := VitalsHud.new()
## canvas_layer.add_child(hud)
## hud.bind(diver.vitals)
## hud.bind_encyclopedia(encyclopedia)
## hud.bind_run_state(run_state)
## hud.bind_population(population)
## [/codeblock]

var _oxygen_bar: ProgressBar
var _health_bar: ProgressBar
var _encyclopedia_label: Label
var _encyclopedia: Encyclopedia
var _run_label: Label
var _run: RunState
var _prey_label: Label
var _population: Population


func _ready() -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(16.0, 16.0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE # the HUD never eats tool clicks
	add_child(box)
	_oxygen_bar = _make_bar(box, Color.DEEP_SKY_BLUE)
	_health_bar = _make_bar(box, Color.RED)
	_encyclopedia_label = _make_label(box)
	_run_label = _make_label(box)
	_prey_label = _make_label(box)


## Connects the bars to [param vitals] and shows its current values.
func bind(vitals: DiverVitals) -> void:
	vitals.oxygen_changed.connect(_set_bar.bind(_oxygen_bar))
	vitals.health_changed.connect(_set_bar.bind(_health_bar))
	_set_bar(vitals.oxygen, vitals.config.max_oxygen, _oxygen_bar)
	_set_bar(vitals.health, vitals.config.max_health, _health_bar)


## Shows [param encyclopedia]'s completion and pending count, kept up to date.
func bind_encyclopedia(encyclopedia: Encyclopedia) -> void:
	_encyclopedia = encyclopedia
	encyclopedia.entry_changed.connect(_update_encyclopedia.unbind(3))
	_update_encyclopedia()


## Shows [param run]'s cargo (fish and value) and money, kept up to date (Story 006).
func bind_run_state(run: RunState) -> void:
	_run = run
	run.cargo_changed.connect(_update_run.unbind(2))
	run.money_changed.connect(_update_run.unbind(1))
	_update_run()


## Shows [param population]'s prey stock and state per layer, kept up to date (Story 007).
func bind_population(population: Population) -> void:
	_population = population
	population.prey_count_changed.connect(_update_prey.unbind(3))
	_update_prey()


func _update_prey() -> void:
	_prey_label.text = _population.describe()


func _update_run() -> void:
	_run_label.text = "Cargo %d fish ($%d)   Money $%d" % [_run.cargo.size(), _run.get_cargo_value(), _run.money]


func _update_encyclopedia() -> void:
	_encyclopedia_label.text = "Encyclopedia %d/%d  pending %d" % [_encyclopedia.completed_count(), _encyclopedia.book.entries.size(), _encyclopedia.pending_count()]


# White text with a dark outline, readable over the bright surface water too.
func _make_label(parent: Control) -> Label:
	var label := Label.new()
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	parent.add_child(label)
	return label


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
