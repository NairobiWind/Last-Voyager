# res://scripts/utilities/MobileInputManager.gd
extends Node

enum Role { MOVE }

# Solo guardamos dedos que efectivamente están moviendo (MOVE)
var move_finger: int = -1

# Tap detection data
var touch_start_time: Dictionary = {}   # pointer_index -> int (ms)
var touch_start_pos: Dictionary = {}    # pointer_index -> Vector2

# Umbrales
const TAP_TIME_MAX_MS: int = 200      # máximo para considerarse tap
const TAP_MOVE_MAX: float = 20.0      # píxeles de tolerancia tap
const DRAG_TO_MOVE_DIST: float = 30.0 # píxeles para iniciar drag→move

@export var joystick_path    : NodePath  # p.ej. "HUD/VirtualJoystick"
@export var player_ship_path : NodePath  # p.ej. "Main/PlayerShip"

@onready var joystick = get_node_or_null(joystick_path)
@onready var player   = get_node_or_null(player_ship_path)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			# inicio de toque: guardamos
			touch_start_time[event.index] = Time.get_ticks_msec()
			touch_start_pos[event.index]  = event.position
		else:
			# release: determinamos tap vs move
			var start_ms = touch_start_time.get(event.index, 0)
			var dt_ms    = Time.get_ticks_msec() - start_ms
			var dist     = touch_start_pos.get(event.index, event.position).distance_to(event.position)

			if dt_ms <= TAP_TIME_MAX_MS and dist <= TAP_MOVE_MAX:
				# tap breve → disparo
				if player:
					player._shoot_bullet(true)
			else:
				# no fue tap: si era move finger, enviar release al joystick
				if event.index == move_finger and joystick:
					joystick._gui_input(event)
			# cleanup
			touch_start_time.erase(event.index)
			touch_start_pos.erase(event.index)
			if event.index == move_finger:
				move_finger = -1
		return

	if event is InputEventScreenDrag:
		# si aún no tenemos finger para mover y el drag supera el umbral, lo asignamos
		if move_finger == -1 and event.position.distance_to(touch_start_pos.get(event.index, event.position)) > DRAG_TO_MOVE_DIST:
			move_finger = event.index
			# reenviamos el down inicial al joystick
			var down = InputEventScreenTouch.new()
			down.index = move_finger
			down.pressed = true
			down.position = touch_start_pos[move_finger]
			joystick._gui_input(down)
		# si ya es nuestro finger de move, le reenviamos este drag
		if event.index == move_finger and joystick:
			joystick._gui_input(event)
		return
