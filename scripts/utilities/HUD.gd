extends CanvasLayer
class_name HUD

# Referencias a las etiquetas de stats
@onready var fuel_label    = $ScreenStats/fuel_row/FuelLabel
@onready var life_label    = $ScreenStats/life_row/LifeLabel
@onready var defense_label = $ScreenStats/defense_row/DefenseLabel

# Botón de menú (está directamente en el HUD)
@onready var menu_button   = $MenuButton

# Mensaje de muerte
@onready var game_over_label = $GameOverLabel

# Fuente de stats
var player_stats: Node = null
var death_handled := false

func _ready() -> void:
	game_over_label.visible = false
	menu_button.connect("pressed", Callable(self, "_on_menu_button_pressed"))

func set_stats_source(_player: Node, p_stats: Node) -> void:
	player_stats = p_stats

func _process(_delta: float) -> void:
	if player_stats:
		fuel_label.text    = " %.1f"   % player_stats.fuel
		life_label.text    = " %d/%d"  % [player_stats.health, player_stats.max_health]
		defense_label.text = " %.1fx"  % player_stats.defense_factor

		if player_stats.health <= 0:
			_on_player_death()

func _on_menu_button_pressed() -> void:
	GameState.save_state()
	get_tree().change_scene_to_file("res://scenes/ui/StartMenu.tscn") # Ajusta la ruta si es diferente

func _on_player_death() -> void:
	if death_handled:
		return
	death_handled = true

	game_over_label.visible = true
	print("💀 El jugador ha muerto")

	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/StartMenu.tscn")  # Ajusta si cambia
