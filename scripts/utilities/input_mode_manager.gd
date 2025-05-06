# res://scripts/utilities/InputModeManager.gd
extends Node

var touch_mode: bool = false

func _ready() -> void:
	# Si es Android o iOS, arranca en modo táctil
	if OS.get_name() in ["Android", "iOS"]:
		touch_mode = true
		print("🌐 Input mode => TOUCH (mobile autodetect)")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F4:
		touch_mode = not touch_mode
		var mode_text = "TOUCH" if touch_mode else "PC"
		print("🌐 Input mode => %s" % mode_text)
