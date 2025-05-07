# res://ui/VirtualJoystick.gd
extends Control

@export var outer_radius: float = 64
@export var inner_radius: float = 24
@export var outer_color: Color  = Color(0.8, 0.8, 0.8, 0.3)
@export var inner_color: Color  = Color(0.8, 0.8, 0.8, 0.9)

var active: bool         = false
var origin: Vector2      = Vector2.ZERO
var direction: Vector2   = Vector2.ZERO
var pos_vector: Vector2  = Vector2.ZERO

func _ready() -> void:
	anchors_preset = PRESET_FULL_RECT
	# Ignorar TODO evento nativo: solo procesaremos los reenviados
	mouse_filter   = MOUSE_FILTER_IGNORE
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	# Procesamos SOLO los eventos reenviados por MobileInputManager
	if event is InputEventScreenTouch:
		active = event.pressed
		if active:
			origin = event.position
			direction = Vector2.ZERO
			pos_vector = Vector2.ZERO
		else:
			direction = Vector2.ZERO
			pos_vector = Vector2.ZERO
		queue_redraw()
		return

	if active and event is InputEventScreenDrag:
		var delta = event.position - origin
		var dist  = delta.length()
		if dist > outer_radius:
			direction   = delta.normalized()
			pos_vector  = direction
		else:
			direction   = delta / outer_radius
			pos_vector  = direction
		queue_redraw()
		return

func _draw() -> void:
	if not active:
		return
	draw_circle(origin, outer_radius, outer_color)
	draw_circle(origin + direction * outer_radius, inner_radius, inner_color)

func get_vector() -> Vector2:
	return pos_vector
