extends Control
class_name VirtualJoystick

# --- Parámetros visuales del joystick ---
@export var outer_radius: float = 64
@export var inner_radius: float = 24
@export var outer_color: Color = Color(0.8, 0.8, 0.8, 0.3)
@export var inner_color: Color = Color(0.8, 0.8, 0.8, 0.9)

# --- Estado interno ---
var active: bool = false
var origin: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var pos_vector: Vector2 = Vector2.ZERO

# --- Fade ---
var fade_speed := 5.0
var target_alpha := 0.0

func _ready() -> void:
	z_index = 10
	anchors_preset = PRESET_FULL_RECT
	mouse_filter = MOUSE_FILTER_IGNORE
	modulate.a = 0.0  # empieza invisible
	queue_redraw()

func _process(delta: float) -> void:
	# Suaviza visibilidad con fade
	modulate.a = lerp(modulate.a, target_alpha, fade_speed * delta)
	queue_redraw()

# --- Dibujo del joystick ---
func _draw() -> void:
	if modulate.a < 0.01:
		return
	draw_circle(origin, outer_radius, outer_color)
	draw_circle(origin + direction * outer_radius, inner_radius, inner_color)

# --- Devuelve la dirección actual ---
func get_vector() -> Vector2:
	return pos_vector

# --- Inicia el joystick ---
func _on_move_started(_index: int, start_pos: Vector2) -> void:
	active = true
	origin = start_pos
	direction = Vector2.ZERO
	pos_vector = Vector2.ZERO
	target_alpha = 1.0
	queue_redraw()

# --- Actualiza la dirección mientras se arrastra ---
func _on_move_updated(_index: int, drag_pos: Vector2) -> void:
	var delta = drag_pos - origin
	var dist = delta.length()
	if dist > outer_radius:
		direction = delta.normalized()
	else:
		direction = delta / outer_radius
	pos_vector = direction
	queue_redraw()

# --- Finaliza el joystick ---
func _on_move_ended(_index: int) -> void:
	active = false
	direction = Vector2.ZERO
	pos_vector = Vector2.ZERO
	target_alpha = 0.0
	queue_redraw()
