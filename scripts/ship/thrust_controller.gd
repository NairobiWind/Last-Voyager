extends Node
class_name ThrustController

# Ya no necesitamos esto:
# @export var particles_path: NodePath

# Enlazamos directo al hijo ThrustParticles
@onready var particles: GPUParticles2D = $ThrustParticles

func set_emitting(state: bool) -> void:
	print("🔄 set_emitting llamado con:", state)
	if particles and particles.emitting != state:
		particles.emitting = state

func _ready() -> void:
	if particles:
		particles.z_index = 10
