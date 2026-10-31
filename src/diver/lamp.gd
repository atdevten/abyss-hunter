class_name Lamp
extends GlowLight
## The diver's lamp: a light around the diver toggled with the L key; off at the
## start of a dive and costs nothing to run. White by default; the red mode (bought
## at the boat in Story 006, a debug switch until then) lights the way without being
## seen by creatures. What creatures do about a seen lamp depends on the diver's
## layer ([member LayerData.lamp_reaction]); they read it through [CreatureContext].
## Add as a child of the diver.
## Implements Story 004 (production/epics/abyss-hunter/story-004-depth-layers-lamp.md).
##
## Usage:
## [codeblock]
## var lamp := Lamp.new()
## lamp.config = load("res://src/diver/diver_config.tres")
## diver.add_child(lamp)
## lamp.lamp_toggled.connect(func(is_on: bool) -> void: print(is_on))
## [/codeblock]

enum Mode { WHITE, RED }

## Toggle key, read by physical key like the diver's movement.
const TOGGLE_KEY := KEY_L

## Emitted when the lamp is switched on or off.
signal lamp_toggled(is_on: bool)

## Injected tuning data. Must be set before the node enters the tree.
@export var config: DiverConfig
## True while the lamp is on.
var is_on: bool = false
## Current light color mode. Change it with [method set_mode].
var mode: Mode = Mode.WHITE


func _ready() -> void:
	set_radius(config.lamp_radius)
	energy = config.lamp_energy
	enabled = false
	set_mode(mode)


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.physical_keycode == TOGGLE_KEY:
		set_on(not is_on)


## Switches the lamp on or off, emitting [signal lamp_toggled] on a change.
func set_on(on: bool) -> void:
	if on == is_on:
		return
	is_on = on
	enabled = on
	lamp_toggled.emit(on)


## Sets the white or red light.
func set_mode(new_mode: Mode) -> void:
	mode = new_mode
	color = config.lamp_red_color if mode == Mode.RED else config.lamp_white_color


## True when creatures can see the lamp: it is on and white.
func is_seen_by_creatures() -> bool:
	return is_on and mode == Mode.WHITE
