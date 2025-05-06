# res://ui/VirtualJoystick.gd
extends Control

@export var outer_radius: float = 64
@export var inner_radius: float = 24
@export var outer_color: Color  = Color(0.1, 0.7, 0.1, 0.5)
@export var inner_color: Color  = Color(0.8, 0.8, 0.8, 0.9)

var active: bool         = false
var origin: Vector2      = Vector2.ZERO
var direction: Vector2   = Vector2.ZERO
var pos_vector: Vector2  = Vector2.ZERO

func _ready() -> void:
	anchors_preset = PRESET_FULL_RECT
	mouse_filter   = MOUSE_FILTER_STOP
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	# Tocar o click inicial
	if (event is InputEventScreenTouch) or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		active = event.pressed
		if active:
			origin = event.position
			direction = Vector2.ZERO
			pos_vector = Vector2.ZERO
		else:
			direction = Vector2.ZERO
			pos_vector = Vector2.ZERO
		queue_redraw()
		accept_event()
		return

	# Arrastrar touch o mouse
	if active and (
			(event is InputEventScreenDrag)
			or (event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT))
		):
		var pos = event.position
		var delta = pos - origin
		var dist  = delta.length()
		if dist > outer_radius:
			direction = delta.normalized()
			pos_vector = direction
		else:
			direction = delta / outer_radius
			pos_vector = direction
		queue_redraw()
		accept_event()
		return

func _draw() -> void:
	if not active:
		return
	draw_circle(origin, outer_radius, outer_color)
	draw_circle(origin + direction * outer_radius, inner_radius, inner_color)

func get_vector() -> Vector2:
	return pos_vector
