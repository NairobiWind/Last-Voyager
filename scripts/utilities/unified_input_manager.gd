# res://scripts/utilities/unified_input_manager.gd
extends Node

signal shoot_requested

# --- Estado de control ---
var move_finger: int = -1
var touch_start_time: Dictionary = {}   # pointer_index -> timestamp
var touch_start_pos: Dictionary = {}    # pointer_index -> posición inicial

# --- Umbrales ---
const TAP_TIME_MAX_MS: int = 200
const TAP_MOVE_MAX: float = 20.0
const DRAG_TO_MOVE_DIST: float = 30.0

# --- Referencias ---
@onready var joystick: Control = get_node_or_null("/root/Main/HUD/VirtualJoystick")
@onready var player_ship: Node = get_node_or_null("/root/Main/PlayerShip")

func _ready():
	if player_ship and not is_connected("shoot_requested", Callable(player_ship, "_on_touch_shoot_requested")):
		connect("shoot_requested", Callable(player_ship, "_on_touch_shoot_requested"))

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_time[event.index] = Time.get_ticks_msec()
			touch_start_pos[event.index] = event.position
			return

		# Al soltar: determinar si fue tap o movimiento (disparo vs joystick)
		var start_ms = touch_start_time.get(event.index, 0)
		var dt_ms = Time.get_ticks_msec() - start_ms
		var dist = touch_start_pos.get(event.index, event.position).distance_to(event.position)

		if dt_ms <= TAP_TIME_MAX_MS and dist <= TAP_MOVE_MAX:
			emit_signal("shoot_requested")
		elif event.index == move_finger and joystick:
			joystick.call("_gui_input", event)

		touch_start_time.erase(event.index)
		touch_start_pos.erase(event.index)
		if event.index == move_finger:
			move_finger = -1
		return

	elif event is InputEventScreenDrag:
		if move_finger == -1:
			var dist = event.position.distance_to(touch_start_pos.get(event.index, event.position))
			if dist > DRAG_TO_MOVE_DIST:
				move_finger = event.index
				# reenviar touch inicial al joystick
				var down = InputEventScreenTouch.new()
				down.index = move_finger
				down.pressed = true
				down.position = touch_start_pos[move_finger]
				joystick.call("_gui_input", down)
		if event.index == move_finger:
			joystick.call("_gui_input", event)
