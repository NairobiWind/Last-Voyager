extends CharacterBody2D

const MAX_SPEED = 600.0
const ACCELERATION = 600.0
const INITIAL_PUSH = 100.0
const FRICTION = 100.0
const BRAKE_FORCE = 300.0

var bullet_scene: PackedScene = preload("res://scenes/ship/bullet.tscn")
var pushing = false
var just_pushed = false

func _physics_process(delta):
	# Consumir combustible si se está intentando mover
	GameStats.consume_thrust(delta)
	z_index = 10

	var mouse_pos = get_global_mouse_position()
	var target_angle = (mouse_pos - global_position).angle()
	rotation = lerp_angle(rotation, target_angle, 5.0 * delta)

	var direction = Vector2.RIGHT.rotated(rotation)

	if GameStats.fuel > 0.0:
		if Input.is_action_just_pressed("ui_up"):
			velocity += direction * INITIAL_PUSH
			just_pushed = true
			pushing = true
		elif Input.is_action_pressed("ui_up"):
			velocity += direction * ACCELERATION * delta
			pushing = true
		else:
			pushing = false
	else:
		pushing = false

	if Input.is_action_pressed("brake"):
		velocity = velocity.move_toward(Vector2.ZERO, BRAKE_FORCE * delta)
	elif not pushing:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

	var forward = Vector2.RIGHT.rotated(rotation)
	var aligned_velocity = forward * velocity.dot(forward)
	velocity = lerp(velocity, aligned_velocity, 0.05)

	$ThrustParticles.emitting = Input.is_action_pressed("ui_up") and GameStats.fuel > 0.0

	move_and_slide()

	handle_shooting()

func handle_shooting():
	if Input.is_action_just_pressed("ui_left") and GameStats.fuel > 0.0 and GameStats.consume_shoot():
		var bullet = bullet_scene.instantiate()

		var fire_direction = Vector2.RIGHT.rotated(rotation)
		var spawn_pos = global_position + fire_direction * 60.0

		bullet.global_position = spawn_pos
		bullet.velocity = fire_direction * bullet.speed
		bullet.rotation = fire_direction.angle()
		bullet.target_position = get_global_mouse_position()

		get_parent().add_child(bullet)
