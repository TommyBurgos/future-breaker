extends Control
func _ready() -> void:
	var box := UIFactory.screen(self, "CONFIGURACIÓN")
	_add_slider(box, "Volumen general", "master")
	_add_slider(box, "Música", "music")
	_add_slider(box, "Efectos", "sfx")
	var vibration := CheckButton.new(); vibration.text = "Vibración"; vibration.button_pressed = bool(SaveManager.data.settings.vibration); vibration.toggled.connect(func(value: bool): SaveManager.data.settings.vibration = value; SaveManager.save_data()); box.add_child(vibration)
	var effects := CheckButton.new(); effects.text = "Efectos visuales"; effects.button_pressed = bool(SaveManager.data.settings.get("visual_effects", true)); effects.toggled.connect(func(value: bool): SaveManager.data.settings.visual_effects = value; SaveManager.save_data()); box.add_child(effects)
	var reset := UIFactory.button(box, "Reiniciar progreso", func(): $Confirm.popup_centered())
	reset.add_theme_color_override("font_color", Color("ff4f87"))
	UIFactory.button(box, "Regresar", func(): SceneManager.go("res://scenes/menus/main_menu.tscn"))
func _add_slider(box: VBoxContainer, label: String, key: String) -> void:
	UIFactory.label(box, label, 24)
	var slider := HSlider.new(); slider.min_value = 0; slider.max_value = 1; slider.step = 0.05; slider.value = float(SaveManager.data.settings[key]); slider.value_changed.connect(func(value: float): SaveManager.data.settings[key] = value; SaveManager.save_data(); AudioManager.apply_settings()); box.add_child(slider)
func _on_confirmed() -> void: SaveManager.reset_progress(); SessionManager.logout(); SceneManager.go("res://scenes/menus/main_menu.tscn")
