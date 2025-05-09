# res://scripts/managers/GameState.gd
extends Node

signal game_loaded(success: bool)

const SAVE_PATH: String = "user://savegame.json"

# Inventario de recursos por tipo
var inventory: Dictionary = {
	"iron": 0,
	"nickel": 0,
	"silicon": 0,
	"aluminum": 0,
	"hydrogen": 0,
	"sodium": 0,
	"palladium": 0,
	"dark_matter": 0,
}

# Estado persistente del jugador y conteo global de asteroides
var last_position: Vector2 = Vector2.ZERO
var last_fuel: float = 100.0
var active_asteroids: int = 0
var regeneration_threshold: int = 100

func _ready() -> void:
	# Mostrar ruta real para depuración
	print("💾 Ruta de guardado real: ", ProjectSettings.globalize_path(SAVE_PATH))
	# Cargar estado al arrancar
	load_state()


func add_loot(resource_name: String, amount: int = 1) -> void:
	inventory[resource_name] = inventory.get(resource_name, 0) + amount
	print("📦 Recolectado: %s | Total: %d" % [resource_name, inventory[resource_name]])

func reset_state() -> void:
	# Restablecer valores a los predeterminados
	for key in inventory.keys():
		inventory[key] = 0
	last_position = Vector2.ZERO
	last_fuel = 100.0
	active_asteroids = 0
	regeneration_threshold = 100

	# Eliminar archivo de guardado si existe
	var dir = DirAccess.open("user://")
	if dir:
		var err = dir.remove("savegame.json")
		if err != OK:
			push_error("No se pudo eliminar “savegame.json”: error %d" % err)
		else:
			print("🗑️ Archivo eliminado: user://savegame.json")
	else:
		push_error("No se pudo abrir user:// para eliminar el fichero.")

func save_state() -> bool:
	var save_data: Dictionary = {
		"inventory": inventory,
		"last_position": {"x": last_position.x, "y": last_position.y},
		"last_fuel": last_fuel,
		"active_asteroids": active_asteroids,
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("No se pudo abrir %s para escritura" % SAVE_PATH)
		return false
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("💾 Estado guardado en %s" % SAVE_PATH)
	return true

func load_state() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("📁 No se encontró archivo de guardado en %s" % SAVE_PATH)
		emit_signal("game_loaded", false)
		return false

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("No se pudo abrir %s para lectura" % SAVE_PATH)
		emit_signal("game_loaded", false)
		return false

	var content: String = file.get_as_text()
	file.close()

	var parser := JSON.new()
	var err: int = parser.parse(content)
	if err != OK:
		push_error("Error parseando JSON: %s en línea %d" % [parser.get_error_message(), parser.get_error_line()])
		emit_signal("game_loaded", false)
		return false

	var data: Dictionary = parser.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Datos de guardado inválidos: se esperaba Dictionary")
		emit_signal("game_loaded", false)
		return false

	# Aplicar datos cargados
	inventory = data.get("inventory", inventory).duplicate(true)
	var pos_item = data.get("last_position", null)
	if typeof(pos_item) == TYPE_DICTIONARY:
		last_position = Vector2(pos_item["x"], pos_item["y"])
	last_fuel = data.get("last_fuel", last_fuel)
	active_asteroids = data.get("active_asteroids", active_asteroids)

	print("✅ Estado cargado desde %s" % SAVE_PATH)
	emit_signal("game_loaded", true)
	return true

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_APPLICATION_PAUSED:
			save_state()
		NOTIFICATION_APPLICATION_RESUMED:
			load_state()
