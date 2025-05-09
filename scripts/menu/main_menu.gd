extends Control
class_name MainMenu

# Referencias a los botones de la barra lateral
@onready var btn_recursos    = $MainContainer/Sidebar/BtnRecursos
@onready var btn_fabricacion = $MainContainer/Sidebar/BtnFabricacion
@onready var btn_mejoras     = $MainContainer/Sidebar/BtnMejoras
@onready var btn_mapa        = $MainContainer/Sidebar/BtnMapa
@onready var btn_misiones    = $MainContainer/Sidebar/BtnMisiones
@onready var btn_ajustes     = $MainContainer/Sidebar/BtnAjustes

# Diccionario de paneles de contenido
@onready var panels = {
	"Recursos":    $MainContainer/ContentArea/PanelRecursos,
	"Fabricacion": $MainContainer/ContentArea/PanelFabricacion,
	"Mejoras":     $MainContainer/ContentArea/PanelMejoras,
	"Mapa":        $MainContainer/ContentArea/PanelMapaGalaxia,
	"Misiones":    $MainContainer/ContentArea/PanelMisiones,
	"Ajustes":     $MainContainer/ContentArea/PanelAjustes
}

var current_section := "Recursos"

func _ready() -> void:
	# Conectar cada botón, uniendo el nombre de la sección con .bind()
	btn_recursos.connect(
		"pressed",
		Callable(self, "_on_section_pressed").bind("Recursos")
	)
	btn_fabricacion.connect(
		"pressed",
		Callable(self, "_on_section_pressed").bind("Fabricacion")
	)
	btn_mejoras.connect(
		"pressed",
		Callable(self, "_on_section_pressed").bind("Mejoras")
	)
	btn_mapa.connect(
		"pressed",
		Callable(self, "_on_section_pressed").bind("Mapa")
	)
	btn_misiones.connect(
		"pressed",
		Callable(self, "_on_section_pressed").bind("Misiones")
	)
	btn_ajustes.connect(
		"pressed",
		Callable(self, "_on_section_pressed").bind("Ajustes")
	)

	# Mostrar únicamente el panel inicial
	_show_only_panel(current_section)


func _on_section_pressed(section_name: String) -> void:
	if section_name == current_section:
		return
	# Ocultar el panel anterior y mostrar el nuevo
	panels[current_section].visible = false
	panels[section_name].visible = true
	current_section = section_name


func _show_only_panel(section_key: String) -> void:
	for key in panels.keys():
		panels[key].visible = (key == section_key)
