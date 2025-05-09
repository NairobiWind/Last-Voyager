extends Node
class_name MobileInputManager

signal shoot_requested

var move_finger: int = -1
var touch_start_time: Dictionary = {}  
var touch_start_pos: Dictionary = {}   

const TAP_TIME_MAX_MS := 200
const TAP_MOVE_MAX := 20.0
const DRAG_TO_MOVE_DIST := 30.0

@export var joystick_path: NodePath
@onready var joystick: Node = get_node_or_null(joystick_path)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_time[event.index] = Time.get_ticks_msec()
			touch_start_pos[event.index] = event.position
			return

		var start_ms = touch_start_time.get(event.index, 0)
		var dt_ms = Time.get_ticks_msec() - start_ms
		var dist = touch_start_pos.get(event.index, event.position).distance_to(event.position)

		if event.index != move_finger and dt_ms <= TAP_TIME_MAX_MS and dist <= TAP_MOVE_MAX:
			print("📲 TAP detectado → disparo")
			emit_signal("shoot_requested")

		if event.index == move_finger and joystick:
			joystick._on_move_ended(event.index)

		touch_start_time.erase(event.index)
		touch_start_pos.erase(event.index)
		if event.index == move_finger:
			move_finger = -1

	elif event is InputEventScreenDrag:
		if move_finger == -1:
			var dist = event.position.distance_to(touch_start_pos.get(event.index, event.position))
			if dist > DRAG_TO_MOVE_DIST:
				move_finger = event.index
				if joystick:
					joystick._on_move_started(event.index, touch_start_pos[move_finger])

		if event.index == move_finger and joystick:
			joystick._on_move_updated(event.index, event.position)
